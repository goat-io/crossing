var jwt = require("jsonwebtoken");
var base64url = require("base64url");
const { base64decode } = require('nodejs-base64');
const utf8 = require('utf8');

const verifyDate = decoded => {
  const now = Date.now().valueOf() / 1000;
  if (decoded.exp >= now) {
    return true;
  }
};

const verifySignature = (token, secret) => {
  if (!token) {
    return false;
  }

  const secretBase64 = Buffer.from(secret, 'base64');
  // const secretJSON = JSON.stringify(secretBuffer);

  try {
    const decoded = jwt.verify(token, secretBase64);
    const valid = verifyDate(decoded);
    if (!valid) {
      throw new Error("Token expired");
    }
    return decoded;
  } catch (e) {
    console.log("e", e);
    return false;
  }
};
const token =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7Il9pZCI6IjVjZDFhYmIzNGM3OTE0MDAxODRlYmIzNCJ9LCJmb3JtIjp7Il9pZCI6IjVjZDFhYmIyNGM3OTE0MDAxODRlYmIxMCJ9LCJpYXQiOjE1NTc5MzE1NjQsImV4cCI6MTU1Nzk0NTk2NH0.BibJITQz16hApieEgrrLMbfrdo_g5kmt9CifCc45wUg";
const secret = "ItJkja_3-NgMX-tobf-arXe1eSUzzBQqB_kxqHfPuCcDjNNq_uLqQpHsKwh7k6uUitgpsuKH8rMelB2ApOMfhQ";

const verify = verifySignature(token, secret);

console.log("verifySignature", verify);