#!/usr/bin/env -S deno run --allow-read --allow-net

// Take "Authorised key" for your service user and place it into this
// folder as `authorized_key.json`.
//
// Run 
//
// $(./init.js)
//
// Then you can use `terraform <cmd>`.
//
// References:
// https://yandex.cloud/ru/docs/iam/operations/iam-token/create-for-sa#node_1

import * as jose from 'https://deno.land/x/jose@v5.4.1/index.ts';

const TOKEN_API = 'https://iam.api.cloud.yandex.net/iam/v1/tokens';
const EXPIRATION = '1h';
const ALGORITHM = 'PS256';

// Reading `authorized_key.json` ...
const authorized = JSON.parse(await Deno.readTextFile('authorized_key.json'));

// Constructing JWT ...
const privateKeyText = authorized.private_key.replace(/^.*\n/, '');
const privateKey = await jose.importPKCS8(privateKeyText, ALGORITHM);
const jwt = await new jose.SignJWT()
    .setProtectedHeader({ kid: authorized.id, alg: ALGORITHM })
    .setIssuedAt()
    .setIssuer(authorized.service_account_id)
    .setAudience(TOKEN_API)
    .setExpirationTime(EXPIRATION)
    .sign(privateKey);

// Getting IAM token ...
const response = await fetch(TOKEN_API, {
    headers: {
        'Content-Type': 'application/json',
    },
    method: 'POST',
    body: JSON.stringify({ jwt }),
});
const payload = await response.json();

console.log(`export TF_VAR_token=${payload.iamToken}`);
