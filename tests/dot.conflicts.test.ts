import { describe, it, expect } from 'vitest';
import { makeTmpDir, makeBin, runDot, list, exists } from './_helpers.js';
import { join } from 'path';
import { writeFileSync } from 'fs';

describe('backup_conflicts', () => {
  it('backs up conflicting target with .pre-stow.<timestamp>', async () => {
    const tmp = makeTmpDir('stubs');
    const stowLog = join(tmp, 'stow.log');

    makeBin(tmp, 'stow', `
      echo "$@" >> "\${LOG}"
      if [[ "$*" == *"-n"* && "$*" == *"-v"* && "$*" == *" -S "* && -n "\${CONFLICT:-}" ]]; then
        echo "WARNING: existing target is not owned by stow: \${CONFLICT}"
      fi
    `);

    const PATH = `${tmp}:${process.env.PATH}`;
    const target = makeTmpDir('home');
    const victim = '.zshrc';
    const victimPath = join(target, victim);
    writeFileSync(victimPath, 'user stuff', 'utf8');

    await runDot(['apply', '--target', target, 'zsh'], {
      env: { PATH, LOG: stowLog, CONFLICT: victim }
    });

    expect(exists(victimPath)).toBe(false);
    const backups = list(target).filter((f) => f.startsWith('.zshrc.pre-stow.'));
    expect(backups.length).toBe(1);
  });
});
