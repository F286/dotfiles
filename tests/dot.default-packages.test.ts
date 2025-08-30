import { describe, it, expect } from 'vitest';
import { makeTmpDir, makeBin, runDot, parsePackagesFromBanner } from './_helpers.js';

function setupWithUname(fake: 'Darwin' | 'Linux') {
  const tmp = makeTmpDir('stubs');
  makeBin(tmp, 'uname', `[[ "\${1:-}" == "-s" ]] && echo "\${FAKE}" || echo "\${FAKE}"`);
  makeBin(tmp, 'stow', `:`);
  const PATH = `${tmp}:${process.env.PATH}`;
  return { PATH, FAKE: fake };
}

describe('default packages per OS', () => {
  it('Darwin includes hammerspoon and excludes vsvim', async () => {
    const { PATH, FAKE } = setupWithUname('Darwin');
    const target = makeTmpDir('home');
    const { stdout } = await runDot(['diff', '--target', target], { env: { PATH, FAKE } });
    const pkgs = parsePackagesFromBanner(stdout);
    expect(pkgs).toContain('hammerspoon');
    expect(pkgs).not.toContain('vsvim');
  });

  it('Linux excludes hammerspoon and vsvim', async () => {
    const { PATH, FAKE } = setupWithUname('Linux');
    const target = makeTmpDir('home');
    const { stdout } = await runDot(['diff', '--target', target], { env: { PATH, FAKE } });
    const pkgs = parsePackagesFromBanner(stdout);
    expect(pkgs).not.toContain('hammerspoon');
    expect(pkgs).not.toContain('vsvim');
  });
});
