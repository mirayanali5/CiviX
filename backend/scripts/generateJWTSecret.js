
const crypto = require('crypto');

const secret = crypto.randomBytes(32).toString('hex');
console.log('\n✅ Generated JWT Secret:');
console.log(`JWT_SECRET=${secret}\n`);
console.log('Copy this to your .env file\n');
