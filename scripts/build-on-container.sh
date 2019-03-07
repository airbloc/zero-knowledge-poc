#!/bin/bash
export PATH=$PATH:/home/zokrates/
cd /home/zokrates/$1

zokrates compile -i $1.py --light
zokrates setup 
zokrates export-verifier
