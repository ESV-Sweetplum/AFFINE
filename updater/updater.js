const { downloadRelease } = require('@terascope/fetch-github-release');
const fs = require("fs")

const user = 'ESV-Sweetplum';
const repo = 'AFFINE';
const outputdir = './';

function filterRelease(release) {
    return !release.prerelease;
}

function filterAsset(asset) {
    return asset.name.includes('AFFINE');
}

async function main() {
    await downloadRelease(user, repo, outputdir, filterRelease, filterAsset)
        .catch((err) => {
            console.error(err.message);
        });

    fs.copyFileSync("./AFFINE/plugin.lua", "./plugin.lua")
    fs.copyFileSync("./AFFINE/settings.ini", "./settings.ini")

    fs.rmSync("./AFFINE", { recursive: true })

    process.exit()
}

main()