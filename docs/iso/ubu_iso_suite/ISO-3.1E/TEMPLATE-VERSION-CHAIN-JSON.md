# Template — `version-chain.json`

```json
{
  "schemaVersion": "1.0",
  "project": {
    "name": "NOME_DO_PROJETO",
    "version": "0.2.0",
    "repository": "URL_DO_REPOSITORIO_OPCIONAL"
  },
  "release": {
    "channel": "release",
    "targetVersion": "0.2.0",
    "promoteTo": ["release", "nightly"],
    "tagPrefix": "v",
    "tagMessage": "Release 0.2.0"
  },
  "branches": {
    "patch": "patch/{version}",
    "release": "release/{version}",
    "nightly": "nightly",
    "stable": "stable"
  },
  "commits": [
    {
      "message": "chore(release): prepare 0.2.0",
      "include": ["."],
      "allowEmpty": false
    }
  ],
  "commands": {
    "beforeAll": [],
    "validation": [
      "make test"
    ],
    "afterAll": []
  },
  "push": {
    "enabled": true,
    "remote": "origin",
    "branches": true,
    "tags": true
  },
  "safety": {
    "requireCleanWorkingTree": false,
    "requireBranch": null,
    "allowBranchCreate": true,
    "allowBranchReset": false
  },
  "docs": {
    "releaseNotesPath": "docs/releases/RELEASE-0.2.0.md",
    "patchNotesPath": "docs/releases/PATCH-0.2.0.md"
  }
}
```
