const fs = require('fs');
const childProcess = require('child_process');

function exec(cmd) {
    return childProcess.execSync(cmd, {stdio: 'inherit'});
}

function toPascalCase(name) {
    return name
        .split('_')
        .map(word => word.charAt(0).toUpperCase() + word.slice(1))
        .join('');
}

function populateCommand(projectName) {
    const proof = JSON.parse(fs.readFileSync(`build/${projectName}/proof.json`).toString());
    
    const params = [...Object.values(proof.proof), proof.input];
    return `(await ${toPascalCase(projectName)}.deployed()).verifyTx.call(${params.map(JSON.stringify).join(',')})`;
}

function main(name, witnesses) {
    const workDir = `/home/zokrates/${name}`;
    exec('docker exec zokrates /home/zokrates/zokrates compute-witness'
        + ` -i ${workDir}/out`
        + ` -o ${workDir}/witness`
        + ` -a ${witnesses.join(' ')}`
    );

    exec('docker exec zokrates /home/zokrates/zokrates generate-proof'
        + ` -w ${workDir}/witness`
        + ` -i ${workDir}/variables.inf`
        + ` -j ${workDir}/proof.json`
        + ` -p ${workDir}/proving.key`
    );
    
    // copy output contract from container and transform
    exec(`docker cp zokrates:${workDir}/proof.json ./build/${name}/`);
    
    console.log('You can run your contract in `npm run console` using:')
    console.log(`    ${populateCommand(name)}`);
}

const projectName = process.argv[2];
if (!projectName) {
    console.log('usage: node scripts/prove.js <project_name> [witnesses...]')
    process.exit(1);
}
main(projectName, process.argv.slice(3));
