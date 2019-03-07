#!/bin/bash
export PATH=$PATH:/home/zokrates/
cd /home/zokrates/$1

zokrates compile -i $1.py --light
zokrates setup --backend gm17
zokrates export-verifier --backend gm17
