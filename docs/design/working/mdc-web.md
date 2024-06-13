Use https://github.com/material-components/material-web

Generate spec files: `wca analyze --format=json --outFile=specs2/all.json`
(https://github.com/runem/web-component-analyzer)

Generate types: `npx ts-json-schema-generator -p all.ts -o types.json`
(https://www.npmjs.com/package/ts-json-schema-generator)
