import "hashes/sha256/512bitPacked.code" as sha256packed

def main(field minimumWage,
         field h1, field h2,
         private field nonce,
         private field mySecretWage) -> (field[2]):
    # check commitment using preimage
    h = sha256packed([mySecretWage, 0, nonce, 0])
    h[0] == h1
    h[1] == h2

    1 == (if mySecretWage >= minimumWage then 1 else 0 fi)
    return h
