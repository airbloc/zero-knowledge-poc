#!/bin/bash
mkdir -p build/$1

# inject script
docker cp build-on-container.sh zokrates:/home/zokrates
docker exec zokrates mkdir -p /home/zokrates/$1/

docker cp src/$1.py zokrates:/home/zokrates/$1
docker exec zokrates /bin/bash /home/zokrates/build-on-container.sh $1

docker cp zokrates:/home/zokrates/$1/verifier.sol build/$1/

node build-helper.js transform ./build/$1/verifier.sol $1
echo "Done! Please run following script in container:"
echo "    cd ~/$1; zokrates compute-witness -a <arguments>"
echo "    zokrates generate-proof"
echo
echo "Then, you can copy the proof using"
echo "    docker cp zokrates:/home/zokrates/$1/proof.json ./build/$1/"
