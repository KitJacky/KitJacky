# JKLabsRandomOracle (BACKEND)

Last Updated: 2024-07-18
Version 0.4

I've developed an application using Python Flask that I'm really excited to show you! It has two handy endpoints. One is for generating random numbers with signatures and Mimblewimble proofs, and the other is for verifying those proofs. Let me give you a quick overview of the main features:

### 1. **`generate_mimblewimble_proof(value)`**
   - This function generates a Mimblewimble proof for a given value.
   - It creates a random scalar `r` and calculates the commitment as `(r * value) % (2**256)`.
   - The proof consists of the scalar `r` and the commitment.

### 2. **`verify_mimblewimble_proof(proof, value)`**
   - This function verifies a Mimblewimble proof.
   - It checks if the commitment in the proof matches the calculation `(r * value) % (2**256)`.

### 3. **`/random` endpoint**
   - **GET method**: This generates a random 64-bit number, hashes it using SHA-256, and then signs the hash using a pre-defined Ethereum private key.
   - It also generates a Mimblewimble proof for the random number.
   - The response includes the random number, its signature, the public key, and the Mimblewimble proof.

### 4. **`/verify` endpoint**s
   - **POST method**: This endpoint takes a JSON payload containing a random number and a Mimblewimble proof.
   - It verifies the proof using the `verify_mimblewimble_proof` function.
   - The response indicates whether the proof is valid.


## Donations

Hi everyone! I'm JackyKit, and I'm really happy to have you here. If you'd like to connect or chat, please don't hesitate to reach out to me. I'd love to hear from you! >> Find me on [X](https://x.com/kitjacky) :-P.

### Support my work and my labs

This project was created in my spare time to share something interesting and useful with the community. Although GitHub hosts this project for free, the backend is using its own server and rented data centre, so maintaining and improving this project and my own lab requires a lot of time, effort and money. If you enjoy using this project and would like to support its continued development, please consider buying me a cup of coffee! I must have two cups a day, so every cup counts!

You can donate via Ethereum to the following address:

**ETH Address:** `0x5b6DB94a3c92Cc8095CeE065265412A700a07405`

Your contributions, no matter how small, go a long way in keeping this project alive and thriving. I genuinely appreciate any support you can offer, whether it’s through a donation, spreading the word, or contributing directly to the project. Thank you so much!

### Other Ways to Support

If you re unable to donate but still want to help, there are several other ways you can contribute:

- **Star the Repository:** If you find this project helpful or interesting, please consider starring the repository. It helps increase visibility and signals to others that this is a project worth exploring.
- **Contribute:** Have an idea, a suggestion, or improvements in mind? Feel free to fork the repo and submit a pull request. Contributions are always welcome and appreciated!
- **Share:** Spread the word by sharing this project with others who might benefit from it. Every share helps grow the community.

Thank you for your support in whatever form it takes. Together, we can continue to make this project even better!

---

JK Labs : https://3jk.net
