const fs = require('fs');
const childProcess = require('child_process');

const header = `
pragma solidity >=0.4.21 <0.6.0;
import "contracts/Pairing.sol";
`.trim();

const migrationTemplate = `
const ContractName = artifacts.require("ContractName");
module.exports = function(deployer) {
    deployer.deploy(ContractName);
};
`.trim();

function exec(cmd) {
    return childProcess.execSync(cmd, {stdio: 'inherit'});
}

function toPascalCase(name) {
    return name
        .split('_')
        .map(word => word.charAt(0).toUpperCase() + word.slice(1))
        .join('');
}

function transformContract(inputPath, projectName) {
    const source = fs.readFileSync(inputPath).toString();

    const newContractName = toPascalCase(projectName);
    const output = header + source
        .slice(source.indexOf('contract Verifier'))
        .replace('contract Verifier', `contract ${newContractName}`);

    fs.writeFileSync(`contracts/${newContractName}.sol`, output);

    // write migrations
    const migration = migrationTemplate.replace(/ContractName/g, newContractName);
    fs.writeFileSync(`migrations/2_${projectName}.js`, migration);
}

function main(name, witnesses) {
    // inject build script
    exec('docker cp scripts/build-on-container.sh zokrates:/home/zokrates');

    // create workdir
    exec(`mkdir -p build/${name}`);
    exec(`docker exec zokrates mkdir -p /home/zokrates/${name}`);
    
    exec(`docker cp src/${name}.py zokrates:/home/zokrates/${name}`);
    exec(`docker exec zokrates /bin/bash /home/zokrates/build-on-container.sh ${name}`);
    
    // copy output contract from container and transform
    exec(`docker cp zokrates:/home/zokrates/${name}/verifier.sol build/${name}/`);
    transformContract(`build/${name}/verifier.sol`, name);

    console.log(
`Done! Please run following script in container:
    cd ~/$1; zokrates compute-witness -a [...arguments]
    zokrates generate-proof

Then, you can copy the proof using
    docker cp zokrates:/home/zokrates/$1/proof.json ./build/$1/

or you can just use:
    npm run prove $1 -- [...arguments]`);
}

const projectName = process.argv[2];
if (!projectName) {
    console.log('usage: node scripts/generate-verifier.js <project_name> [witnesses...]')
    process.exit(1);
}
main(projectName, process.argv.slice(3));
