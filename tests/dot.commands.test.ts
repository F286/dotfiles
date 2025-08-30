import { describe, it, expect } from 'vitest';
import { makeTmpDir, makeBin, runDot, repoRoot, read } from './_helpers.js';
import { join } from 'path';

function setupStubbedPATH(env: Record<string, string> = {}) {
  const tmp = makeTmpDir('stubs');
  const log = join(tmp, 'stow.log');

  makeBin(tmp, 'stow', `
    echo "$@" >> "\${LOG}"
  `);

  const PATH = `${tmp}:${process.env.PATH}`;
  return { PATH, tmp, log, env: { ...env, LOG: log } };
}

describe('dot subcommand wiring', () => {
  it('diff uses -n -v and -S', async () => {
    const { PATH, env, log } = setupStubbedPATH();
    const target = makeTmpDir('home');
    const { stdout } = await runDot(['diff', '--target', target, 'foo'], { env: { PATH, ...env } });
    const line = read(log).trim();
    expect(line).toContain('-n');
    expect(line).toContain('-v');
    expect(line).toContain('-S foo');
    expect(stdout).toMatch(/dot diff: os=/);
  });

  it('apply uses -S', async () => {
    const { PATH, env, log } = setupStubbedPATH();
    const target = makeTmpDir('home');
    await runDot(['apply', '--target', target, 'foo', 'bar'], { env: { PATH, ...env } });
    const line = read(log).trim().split('\n').pop()!;
    expect(line).toContain('-S foo bar');
  });

  it('restow uses -R', async () => {
    const { PATH, env, log } = setupStubbedPATH();
    const target = makeTmpDir('home');
    await runDot(['restow', '--target', target, 'pkg1'], { env: { PATH, ...env } });
    const line = read(log).trim();
    expect(line).toContain('-R pkg1');
  });

  it('delete uses -D', async () => {
    const { PATH, env, log } = setupStubbedPATH();
    const target = makeTmpDir('home');
    await runDot(['delete', '--target', target, 'pkgZ'], { env: { PATH, ...env } });
    const line = read(log).trim();
    expect(line).toContain('-D pkgZ');
  });

  it('update calls git pull then restow (-R)', async () => {
    const tmp = makeTmpDir('stubs');
    const stowLog = join(tmp, 'stow.log');
    const gitLog = join(tmp, 'git.log');

    makeBin(tmp, 'stow', `echo "$@" >> "\${STOW_LOG}"`);
    makeBin(tmp, 'git', `echo "git $@" >> "\${GIT_LOG}"`);

    const PATH = `${tmp}:${process.env.PATH}`;
    const target = makeTmpDir('home');
    await runDot(['update', '--target', target, 'abc'], {
      env: { PATH, STOW_LOG: stowLog, GIT_LOG: gitLog }
    });

    const gitLine = read(gitLog).trim();
    expect(gitLine).toMatch(/git -C .*dotfiles.* pull --ff-only/);

    const stowLine = read(stowLog).trim().split('\n').pop()!;
    expect(stowLine).toContain('-R abc');
  });
});
