export default async function Page(){
 let data={}; try { data=await (await fetch('http://api:8080/api/admin/dashboard',{cache:'no-store'})).json() } catch(e){}
 return <main style={{fontFamily:'Arial',padding:32}}>
 <h1>🙏 ONLINE VIDEO PRAYER MANAGEMENT</h1>
 <p>Christian Prayer Platform — Super Admin</p>
 <div style={{display:'flex',gap:16,flexWrap:'wrap'}}>{Object.entries(data).map(([k,v])=><div key={k} style={{padding:20,border:'1px solid #ddd',borderRadius:10,minWidth:180}}><b>{k.replaceAll('_',' ')}</b><h2>{v}</h2></div>)}</div>
 <hr/><h2>Management Modules</h2><ul><li>Prayer Requests</li><li>Online Video Prayer</li><li>House Visits</li><li>Prayer Team</li><li>Vendors</li><li>Products & Inventory</li><li>Orders & Delivery</li><li>Offerings</li><li>Payments</li><li>Notifications</li><li>Support</li><li>Reports & Analytics</li></ul>
 </main>
}
