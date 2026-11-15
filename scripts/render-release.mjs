// No external dependencies. Requires Node.js 22+.
// Supports Render services connected to Git (default) or to prebuilt GHCR images.
// Never runs schema initialization or Prisma db push on production.
const required = (name) => {
  const value = process.env[name]?.trim();
  if (!value) throw new Error(`Missing GitHub Actions secret/variable: ${name}`);
  return value;
};
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
const key = required('RENDER_API_KEY');
const mode = process.env.RENDER_DEPLOY_MODE?.trim() || 'git';
if (!['git', 'image'].includes(mode)) throw new Error('RENDER_DEPLOY_MODE must be git or image');
const origin = 'https://api.render.com/v1';
const headers = { Authorization: `Bearer ${key}`, Accept: 'application/json', 'Content-Type': 'application/json' };
const sha = required('GITHUB_SHA');
const apiId = required('RENDER_API_SERVICE_ID');
const webId = required('RENDER_WEB_SERVICE_ID');
const apiPublic = new URL(required('NEXT_PUBLIC_API_URL'));
const webPublic = new URL(required('PRODUCTION_WEB_URL'));
if (apiPublic.protocol !== 'https:' || webPublic.protocol !== 'https:') throw new Error('Public URLs must use HTTPS');
if (!apiId.startsWith('srv-') || !webId.startsWith('srv-')) throw new Error('Render service IDs must start with srv-');
const apiImg = mode === 'image' ? required('API_IMAGE_URL') : null;
const webImg = mode === 'image' ? required('WEB_IMAGE_URL') : null;

async function apiRequest(path, init = {}) {
  const response = await fetch(origin + path, { ...init, headers });
  const body = await response.text();
  if (!response.ok) throw new Error(`Render API ${response.status}: ${body.slice(0, 500)}`);
  return body ? JSON.parse(body) : {};
}
async function deploy(name, id, imageUrl) {
  console.log(`Starting ${name} deployment (${mode}, version ${sha.slice(0, 8)})`);
  const body = mode === 'git' ? { commitId: sha } : { imageUrl };
  const response = await apiRequest(`/services/${id}/deploys`, {
    method: 'POST', body: JSON.stringify(body),
  });
  const deployId = response.id || response.deploy?.id;
  if (!deployId) throw new Error(`${name}: Render did not return a deployment ID`);
  console.log(`${name}: deploy ID ${deployId}, waiting for Live status...`);
  const stopAt = Date.now() + 25 * 60 * 1000;
  while (Date.now() < stopAt) {
    const response = await apiRequest(`/services/${id}/deploys/${deployId}`);
    const status = response.status || response.deploy?.status;
    if (status === 'live') {
      console.log(`${name}: deployment ${deployId} is Live`);
      return;
    }
    if (['build_failed', 'update_failed', 'pre_deploy_failed', 'canceled', 'deactivated'].includes(status)) {
      throw new Error(`${name}: deployment ${deployId} failed with status ${status}`);
    }
    console.log(`${name}: ${status || 'unknown'}...`);
    await sleep(10000);
  }
  throw new Error(`${name}: timed out waiting for Render deployment ${deployId}`);
}
async function smoke(label, root, path, validate) {
  const url = new URL(path, root).toString();
  const stopAt = Date.now() + 3 * 60 * 1000;
  let lastError = 'no attempt';
  while (Date.now() < stopAt) {
    try {
      const response = await fetch(url, { signal: AbortSignal.timeout(15000), redirect: 'follow' });
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      await validate(response);
      console.log(`${label}: smoke test passed (${url})`);
      return;
    } catch (error) {
      lastError = error.message;
      await sleep(7000);
    }
  }
  throw new Error(`${label}: smoke failed (${lastError})`);
}
await deploy('API', apiId, apiImg);
await smoke('API health', apiPublic, '/health', async () => {});
await smoke('API products', apiPublic, '/products', async (response) => {
  const items = await response.json();
  if (!Array.isArray(items) || items.length === 0) throw new Error('Menu missing or empty');
});
await deploy('Web', webId, webImg);
await smoke('Web homepage', webPublic, '/', async (response) => {
  const contentType = response.headers.get('content-type') || '';
  if (!contentType.includes('text/html')) throw new Error('Expected HTML homepage');
});
console.log('Release done: both Render deployments live and HTTP smoke checks passed');
