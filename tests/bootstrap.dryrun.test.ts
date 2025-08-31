import { describe, it, expect } from 'vitest';
import { makeTmpDir, makeBin, repoRoot } from './_helpers.js';
import { execFile as _execFile } from 'child_process';
import { promisify } from 'util';
import { join } from 'path';
const execFile = promisify(_execFile);

describe('bootstrap.sh DRYRUN', () => {
  it('prints DRYRUN banner and completes', async () => {
    const stubs = makeTmpDir('stubs');
    makeBin(stubs, 'stow', `:`);

    const PATH = `${stubs}:${process.env.PATH}`;
    const { stdout } = await execFile(join(repoRoot, 'scripts/bootstrap.sh'), [], {
      env: { ...process.env, DRYRUN: '1', PATH },
      cwd: repoRoot
    });

    expect(stdout).toMatch(/DRYRUN=1: skipping installations; previewing stow changes/i);
    expect(stdout).toMatch(/✅ Bootstrap complete\./);
  });
});
