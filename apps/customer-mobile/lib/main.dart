import 'package:flutter/material.dart';
void main()=>runApp(const App());
class App extends StatelessWidget{const App({super.key});Widget build(BuildContext c)=>MaterialApp(debugShowCheckedModeBanner:false,title:'Christian Prayer',theme:ThemeData(useMaterial3:true,colorSchemeSeed:Colors.indigo),home:const Home());}
class Home extends StatelessWidget{const Home({super.key});Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('🙏 Christian Prayer Platform')),body:ListView(padding:const EdgeInsets.all(16),children:[
const Text('Welcome',style:TextStyle(fontSize:28,fontWeight:FontWeight.bold)),const Text('Discover • Pray • Request • Book • Purchase • Support'),const SizedBox(height:16),
...['🙏 REQUEST PRAYER','📹 ONLINE VIDEO PRAYER','🏠 BOOK HOUSE VISIT','🫒 ORDER PRAYER OIL','🎁 OFFERINGS','🛒 SHOP DEVOTIONAL PRODUCTS'].map((x)=>Card(child:ListTile(title:Text(x,style:const TextStyle(fontWeight:FontWeight.bold)),trailing:const Icon(Icons.chevron_right),onTap:()=>x.contains('VIDEO')?Navigator.push(c,MaterialPageRoute(builder:(_)=>const Booking())):null)))
]));}
class Booking extends StatefulWidget{const Booking({super.key});State<Booking> createState()=>_B();}
class _B extends State<Booking>{final f=GlobalKey<FormState>();String cat='Personal Prayer',typ='Individual';Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('📹 Book Online Prayer')),body:Form(key:f,child:ListView(padding:const EdgeInsets.all(16),children:[
const Text('Private Online Video Prayer',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),
...['Name','Mobile number','Email','Prayer request','Additional notes'].map((x)=>Padding(padding:const EdgeInsets.only(top:10),child:TextFormField(maxLines:x.contains('request')||x.contains('notes')?3:1,decoration:InputDecoration(labelText:x,border:const OutlineInputBorder()),validator:(v)=>x=='Additional notes'?null:(v==null||v.isEmpty?'Required':null)))),
const SizedBox(height:10),DropdownButtonFormField(value:cat,items:['Personal Prayer','Family Prayer','Thanksgiving Prayer','Bible Prayer','Special Prayer Request','Counseling/Spiritual Fellowship','Emergency Prayer Request'].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),onChanged:(v)=>setState(()=>cat=v!),decoration:const InputDecoration(labelText:'Prayer category',border:OutlineInputBorder())),
const SizedBox(height:10),DropdownButtonFormField(value:typ,items:['Individual','Family','Group'].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),onChanged:(v)=>setState(()=>typ=v!),decoration:const InputDecoration(labelText:'Session type',border:OutlineInputBorder())),
const SizedBox(height:16),FilledButton(onPressed:(){if(f.currentState!.validate())showDialog(context:c,builder:(_)=>AlertDialog(title:const Text('Booking submitted 🙏'),content:const Text('Your request will be confirmed after slot and authorized prayer minister availability.'),actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('OK'))]));},child:const Padding(padding:EdgeInsets.all(14),child:Text('CONTINUE TO REVIEW')))
])));}
}
