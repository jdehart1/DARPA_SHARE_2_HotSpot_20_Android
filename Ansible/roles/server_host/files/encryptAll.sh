#!/bin/bash

# unencrypted in dir: RussianImage
# encrypted in dir  : RussianImageEncrypted
UNENCRYPTED_DIR="RussianImage"
ENCRYPTED_DIR="RussianImageEncrypted"
cd $UNENCRYPTED_DIR
FILES=`ls *`
cd ..
echo "FILES: $FILES"
for f in $FILES
do
  echo "encrypting $f"
  openssl enc -aes-256-cbc -kfile password -in  $UNENCRYPTED_DIR/$f -out $ENCRYPTED_DIR/${f}.enc
done
