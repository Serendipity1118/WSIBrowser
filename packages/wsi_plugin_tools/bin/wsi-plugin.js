#!/usr/bin/env node
// wsi-plugin: plugin developer CLI for WSI Browser / WSI (Chrome).
//
//   wsi-plugin create <id> [--dir <path>] [--name <name>]
//   wsi-plugin validate [dir]
//   wsi-plugin build [dir] [--minify] [--sourcemap]
//   wsi-plugin pack [dir] [--out <file>] [--minify]
//   wsi-plugin dev-serve [dir] [--port 8443] [--host <ip>] [--no-qr]
//   wsi-plugin publish [dir]            (added in PB)
import { parseArgs } from 'node:util';
import { resolve, relative } from 'node:path';
import { create, validate, build, pack } from '../src/index.js';

const USAGE = `wsi-plugin <command> [options]

commands:
  create <id> [--dir <path>] [--name <name>]   generate a plugin from the template
  validate [dir]                                check plugin.json and referenced files
  build [dir] [--minify] [--sourcemap]          bundle src/main.js (+ src/worker.js) into dist/ with esbuild
  pack [dir] [--out <file>] [--minify]          validate + build + ZIP (dist/<id>-<version>.zip)
  dev-serve [dir] [--port 8443] [--host <ip>]   serve the ZIP over HTTPS for WSI Browser developer mode
  publish [dir]                                 upload to Cloudflare (not implemented yet: PB-07)
`;

function fail(message, code = 1) {
  console.error(message);
  process.exit(code);
}

async function main() {
  const { values, positionals } = parseArgs({
    allowPositionals: true,
    options: {
      dir: { type: 'string' },
      name: { type: 'string' },
      out: { type: 'string' },
      port: { type: 'string' },
      host: { type: 'string' },
      minify: { type: 'boolean', default: false },
      sourcemap: { type: 'boolean', default: false },
      'no-qr': { type: 'boolean', default: false },
      help: { type: 'boolean', short: 'h', default: false },
    },
  });
  const [command, arg] = positionals;
  if (values.help || !command) {
    console.log(USAGE);
    process.exit(command ? 0 : 1);
  }

  switch (command) {
    case 'create': {
      if (!arg) fail('usage: wsi-plugin create <id> [--dir <path>] [--name <name>]');
      const target = create(arg, { dir: values.dir, name: values.name });
      console.log(`created ${relative(process.cwd(), target) || '.'}`);
      console.log('next: edit plugin.json (domains, permissions), add src/features/*.js, then `wsi-plugin pack`');
      return;
    }
    case 'validate': {
      const dir = resolve(arg || '.');
      const { def, errors } = validate(dir);
      if (errors.length) {
        console.error(`plugin.json has ${errors.length} problem(s):`);
        for (const e of errors) console.error(`  - ${e}`);
        process.exit(1);
      }
      console.log(`ok: ${def.id} v${def.version} (format v${def.formatVersion || 1})`);
      return;
    }
    case 'build': {
      const dir = resolve(arg || '.');
      const outputs = await build(dir, { minify: values.minify, sourcemap: values.sourcemap });
      if (outputs.length === 0) console.log('nothing to build (no src/main.js)');
      for (const o of outputs) console.log(`built ${relative(process.cwd(), o)}`);
      return;
    }
    case 'pack': {
      const dir = resolve(arg || '.');
      const { zipPath, files, def } = await pack(dir, { out: values.out, minify: values.minify });
      console.log(`packed ${def.id} v${def.version} -> ${relative(process.cwd(), zipPath)}`);
      for (const f of files) console.log(`  ${f}`);
      return;
    }
    case 'dev-serve': {
      const dir = resolve(arg || '.');
      const { serve } = await import('../src/serve.js');
      await serve(dir, { port: values.port ? Number(values.port) : undefined, host: values.host, minify: values.minify, noQr: values['no-qr'] });
      return; // keeps running
    }
    case 'publish':
      fail('publish is not implemented yet (planned in PB-07)');
      return;
    default:
      fail(`unknown command: ${command}\n\n${USAGE}`);
  }
}

main().catch((e) => fail(e && e.message ? e.message : String(e)));
