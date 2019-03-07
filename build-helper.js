const fs = require('fs');

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

function toPascalCase(name) {
    return name
        .split('_')
        .map(word => word.charAt(0).toUpperCase() + word.slice(1))
        .join('');
}

const commands = {
    transform(args) {
        if (args.size < 2) {
            console.log('usage: node build-helper.js transform <source_file> <project_name>');
            return 1;
        }
        const [inputPath, projectName] = args;
        const source = fs.readFileSync(inputPath).toString();

        const newContractName = toPascalCase(projectName);
        const output = header + source
            .slice(source.indexOf('contract Verifier'))
            .replace('contract Verifier', `contract ${newContractName}`);

        fs.writeFileSync(`contracts/${newContractName}.sol`, output);

        // write migrations
        const migration = migrationTemplate.replace(/ContractName/g, newContractName);
        fs.writeFileSync(`migrations/2_${projectName}.js`, migration);
    },
    command(args) {
        if (args.size < 1) {
            console.log('usage: node build-helper.js command <project_name>');
            return 1;
        }
        const [projectName] = args;
        const proof = JSON.parse(fs.readFileSync(`build/${projectName}/proof.json`).toString());
        
        const params = [...Object.values(proof.proof), proof.input];
        console.log(`(await ${toPascalCase(projectName)}.deployed()).verifyTx.call(${params.map(JSON.stringify).join(',')})`);
    }
};

const command = process.argv[2];
if (!commands[command]) {
    console.log(`usage: node build-helper.js [${Object.keys(commands).join('|')}]`);
    process.exit(1);
}

process.exit(commands[command](process.argv.slice(3)) || 0);
