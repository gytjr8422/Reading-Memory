const functions = require("firebase-functions");
const admin = require("firebase-admin");
const jwt = require("jsonwebtoken");
const fs = require("fs");
const axios = require("axios");
const qs = require("qs");

admin.initializeApp();

/**
 * Function to make JWT
 * @return {string} The JWT token
 */
function makeJWT() {
  const privateKey = fs.readFileSync("AuthKey_DLSYRMXM68.p8");
  const token = jwt.sign({
    iss: "UQ7969NVUB",
    iat: Math.floor(Date.now() / 1000),
    exp: Math.floor(Date.now() / 1000) + 120,
    aud: "https://appleid.apple.com",
    sub: "com.hskim.ReadingMemory",
  }, privateKey, {
    algorithm: "ES256",
    header: {
      alg: "ES256",
      kid: "DLSYRMXM68",
    },
  });
  return token;
}

exports.getRefreshToken = functions.https.onRequest(
    async (request, response) => {
      const code = request.query.code;
      const clientSecret = makeJWT();
      const data = {
        code: code,
        client_id: "com.hskim.ReadingMemory",
        client_secret: clientSecret,
        grant_type: "authorization_code",
      };
      return axios.post("https://appleid.apple.com/auth/token", qs.stringify(data), {
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
      })
          .then(async (res) => {
            const refreshToken = res.data.refresh_token;
            response.send(refreshToken);
          });
    });

exports.revokeToken = functions.https.onRequest(async (request, response) => {
  const refreshToken = request.query.refresh_token;
  const clientSecret = makeJWT();
  const data = {
    token: refreshToken,
    client_id: "com.hskim.ReadingMemory",
    client_secret: clientSecret,
    token_type_hint: "refresh_token",
  };
  return axios.post("https://appleid.apple.com/auth/revoke", qs.stringify(data), {
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
  })
      .then(async (res) => {
        console.log(res.data);
        response.send("Complete");
      });
});
