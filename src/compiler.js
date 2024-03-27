const fs = require("fs");
const path = require("path");

const getFilesRecursively = (directory) => {

    let files = [];

    const filesInDirectory = fs.readdirSync(directory);
    for (const file of filesInDirectory) {
        const absolute = path.join(directory, file);
        if (fs.statSync(absolute).isDirectory()) {
            files = [...files, ...getFilesRecursively(absolute)];
        } else {
            files.push(absolute);
        }
    }

    return files;
};

const CONSTANT_FILES = getFilesRecursively("./src/CONSTANTS").map((file) => fs.readFileSync(file, 'utf-8'))

const FUNCTION_TABLES = CONSTANT_FILES.reduce((str, file) => {
    const idx = file.split("\n").findIndex((v) => v.includes('FUNCTIONS'))
    console.log(file.split("\n").slice(idx))

    if (idx === -1) return;

    return `${str} \n \n ${file.split('\r\n').slice(idx).join("\n")}`
}, '')

const CONSTANTS = CONSTANT_FILES.reduce((str, file) => {
    const idx = file.split("\r\n").findIndex((v) => v.includes('FUNCTIONS'))
    if (idx === -1) {
        return `${str} \n \n ${file}`
    }
    return `${str} \n \n ${file.split('\r\n').slice(0, idx - 1).join("\n")}`
}, '')


let mainFile = fs.readFileSync('./src/main.lua', 'utf-8').replace("-- {function tables}", FUNCTION_TABLES)

const IGNORED_FILES = [
    'CONSTANTS',
    'main.lua'
]

let files = getFilesRecursively("./src").filter((file) => file.endsWith(".lua")).filter((file) => !IGNORED_FILES.some((v) => file.includes(v)))

files.forEach((file) => {
    mainFile = `${fs.readFileSync(file, 'utf-8')} \n \n ${mainFile}`
})

fs.writeFileSync("./plugin.lua", `${CONSTANTS} \n \n ${mainFile}`)