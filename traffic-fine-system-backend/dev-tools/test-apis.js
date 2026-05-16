const BASE = 'http://localhost:3000';
const adminCreds = { username: 'admin', password: 'fines1234@#' };

async function req(path, opts = {}){
  try{
    const res = await fetch(BASE + path, opts);
    let body;
    const ct = res.headers.get('content-type') || '';
    if (ct.includes('application/json')) body = await res.json(); else body = await res.text();
    return { status: res.status, body };
  }catch(e){
    return { error: e.message };
  }
}

(async ()=>{
  console.log('1) GET /');
  console.log(await req('/'));

  console.log('\n2) POST /auth/login');
  const login = await req('/auth/login', { method: 'POST', headers: {'content-type':'application/json'}, body: JSON.stringify(adminCreds) });
  console.log(login);

  const token = login.body && login.body.access_token ? login.body.access_token : null;
  if(!token) return console.log('\nLogin failed, aborting further tests');

  const auth = { headers: { Authorization: 'Bearer ' + token } };

  console.log('\n3) GET /fines/protected');
  console.log(await req('/fines/protected', auth));

  console.log('\n4) GET /fines/admin-only');
  console.log(await req('/fines/admin-only', auth));

  console.log('\n5) GET /fines/REF123');
  console.log(await req('/fines/REF123', auth));

  console.log('\n6) POST /payments/pay');
  console.log(await req('/payments/pay', { method: 'POST', headers: {...auth.headers, 'content-type':'application/json'}, body: JSON.stringify({ fineId: 1, amount: 100 }) }));

  console.log('\n7) GET /admin/total-collections');
  console.log(await req('/admin/total-collections', auth));

  console.log('\n8) GET /admin/district-collections');
  console.log(await req('/admin/district-collections', auth));

  console.log('\n9) GET /admin/category-breakdown');
  console.log(await req('/admin/category-breakdown', auth));

  process.exit(0);
})();
