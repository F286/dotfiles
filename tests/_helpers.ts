import { mkdtempSync, writeFileSync, mkdirSync, chmodSync, readFileSync, readdirSync, existsSync } from 'fs';
import { tmpdir } from 'os';
import { join, dirname, resolve } from 'path';
import { fileURLToPath } from 'url';
import { execFile as _execFile } from 'child_process';
import { promisify } from 'util';

const execFile = promisify(_execFile);
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
export const repoRoot = resolve(__dirname, '..');

export function makeTmpDir(prefix: string) {
  return mkdtempSync(join(tmpdir(), `${prefix}-`));
}

export function makeBin(dir: string, name: string, body: string) {
  const p = join(dir, name);
  writeFileSync(p, `#!/usr/bin/env bash\nset -euo pipefail\n${body}\n`);
  chmodSync(p, 0o755);
  return p;
}

export async function runDot(args: string[], opts?: { env?: Record<string, string>; cwd?: string }) {
  const bin = resolve(repoRoot, 'dot');
  const { stdout, stderr } = await execFile(bin, args, {
    cwd: opts?.cwd ?? repoRoot,
    env: { ...process.env, ...(opts?.env ?? {}) }
  });
  return { stdout: String(stdout), stderr: String(stderr) };
}

export function read(path: string) {
  return readFileSync(path, 'utf8');
}

export function list(dir: string) {
  return readdirSync(dir);
}

export function exists(path: string) {
  return existsSync(path);
}

export function parsePackagesFromBanner(out: string): string[] {
  const m = out.match(/packages:\s*([^\n]+)/);
  if (!m) return [];
  return m[1].trim().split(/\s+/).filter(Boolean);
}
