
import 'package:flutter/material.dart';
import 'foodloop_engine.dart';

void main() => runApp(const FoodLoopApp());

const bg = Color(0xFF0D1511), panel = Color(0xFF17231C),
    panel2 = Color(0xFF203128), green = Color(0xFF48D18A),
    muted = Color(0xFF9AAFA2);

class FoodLoopApp extends StatelessWidget {
  const FoodLoopApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'FoodLoop', debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark, scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(primary: green, surface: panel),
      useMaterial3: true,
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: panel,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    ),
    home: const LoginScreen(),
  );
}

class Meal {
  Meal(this.id,this.name,this.cafe,this.location,this.kind,this.qty,this.deadline,this.allergens,this.description);
  final String id,name,cafe,location,kind,deadline,allergens,description;
  int qty;
}
final meals = <Meal>[
  Meal('FL1024','Vegetable Rice Bowl','Main Cafeteria','Block 2 · Ground Floor','Vegetarian',18,'2:30 PM','May contain traces of soy. Confirm with staff.','Freshly prepared vegetable rice portions.'),
  Meal('FL1025','Idli & Sambar Pack','North Campus Cafe','Academic Block · Canteen','Vegan',12,'1:45 PM','No allergen declaration supplied. Ask staff.','Four idlis with sambar, packed for collection.'),
  Meal('FL1026','Chapati Meal','Hostel Mess','Hostel Zone · Counter 1','Vegetarian',8,'3:00 PM','Contains wheat; may contain milk.','Chapati with vegetable kurma.'),
];
class Pickup {
  Pickup(this.code,this.meal,this.count);
  final String code; final Meal meal; final int count;
  bool collected=false;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState()=>_LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final email=TextEditingController(), password=TextEditingController();
  String role='Student';

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void enter() {
    final e=email.text.trim();
    if(!e.contains('@') || password.text.trim().length<4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Enter a valid email and a demo password (4+ characters).')));
      return;
    }
    Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>role=='Student'
        ? StudentShell(email:e)
        : role=='Admin' ? AdminDashboard(email:e) : CafeteriaScreen(email:e)));
  }
  @override Widget build(BuildContext context)=>Scaffold(body:SafeArea(child:Center(child:SingleChildScrollView(padding:const EdgeInsets.all(26),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const SizedBox(height:30),
    Container(width:66,height:66,decoration:BoxDecoration(color:green.withOpacity(.14),borderRadius:BorderRadius.circular(22)),child:const Icon(Icons.eco_rounded,color:green,size:38)),
    const SizedBox(height:24),
    const Text('FoodLoop',style:TextStyle(fontSize:36,fontWeight:FontWeight.w800)),
    const SizedBox(height:6),const Text('Good food deserves another chance.',style:TextStyle(color:muted)),
    const SizedBox(height:34),const Text('Welcome to your campus food community',style:TextStyle(fontSize:21,fontWeight:FontWeight.w700)),
    const SizedBox(height:20),const Text('COLLEGE EMAIL',style:TextStyle(color:muted,fontSize:11,letterSpacing:1.2)),
    const SizedBox(height:7),TextField(controller:email,keyboardType:TextInputType.emailAddress,decoration:const InputDecoration(prefixIcon:Icon(Icons.mail_outline),hintText:'name@college.edu')),
    const SizedBox(height:15),const Text('PASSWORD',style:TextStyle(color:muted,fontSize:11,letterSpacing:1.2)),
    const SizedBox(height:7),TextField(controller:password,obscureText:true,decoration:const InputDecoration(prefixIcon:Icon(Icons.lock_outline),hintText:'Enter password')),
    const SizedBox(height:18),const Text('CONTINUE AS',style:TextStyle(color:muted,fontSize:11,letterSpacing:1.2)),
    const SizedBox(height:8),SegmentedButton<String>(segments:const[
      ButtonSegment(value:'Student',label:Text('Student'),icon:Icon(Icons.school_outlined)),
      ButtonSegment(value:'Cafeteria',label:Text('Cafeteria'),icon:Icon(Icons.restaurant_outlined)),
      ButtonSegment(value:'Admin',label:Text('Admin'),icon:Icon(Icons.admin_panel_settings_outlined)),
    ],selected:{role},onSelectionChanged:(s)=>setState(()=>role=s.first)),
    const SizedBox(height:22),SizedBox(width:double.infinity,height:54,child:FilledButton(
      onPressed:enter,style:FilledButton.styleFrom(backgroundColor:green,foregroundColor:bg),
      child:const Text('Continue',style:TextStyle(fontWeight:FontWeight.bold,fontSize:16)))),
    const SizedBox(height:14),const Center(child:Text('DEMO MODE · Real college email verification is a Firebase integration step',textAlign:TextAlign.center,style:TextStyle(color:muted,fontSize:11))),
  ])))));
}

class StudentShell extends StatefulWidget {
  const StudentShell({super.key,required this.email}); final String email;
  @override State<StudentShell> createState()=>_StudentShellState();
}
class _StudentShellState extends State<StudentShell>{
  int tab=0; final pickups=<Pickup>[];
  void reserve(Meal m,int count){
    setState(() {
      m.qty -= count;
      pickups.insert(0, Pickup('FL-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}', m, count));
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Reservation confirmed.')));
    setState(()=>tab=1);
  }
  @override Widget build(BuildContext context){
    final pages=[
      DiscoverScreen(onReserve:reserve),
      PickupsScreen(pickups:pickups,onCollected:(p)=>setState(()=>p.collected=true)),
      ImpactScreen(pickups:pickups),
      ProfileScreen(email:widget.email,onLogout:()=>Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder:(_)=>const LoginScreen()),(r)=>false)),
    ];
    return Scaffold(body:pages[tab],bottomNavigationBar:NavigationBar(
      backgroundColor:panel,indicatorColor:green.withOpacity(.16),selectedIndex:tab,
      onDestinationSelected:(v)=>setState(()=>tab=v),
      destinations:const[
        NavigationDestination(icon:Icon(Icons.explore_outlined),label:'Discover'),
        NavigationDestination(icon:Icon(Icons.confirmation_number_outlined),label:'My pickups'),
        NavigationDestination(icon:Icon(Icons.eco_outlined),label:'My impact'),
        NavigationDestination(icon:Icon(Icons.person_outline),label:'Profile'),
      ]));
  }
}

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key,required this.onReserve}); final void Function(Meal,int) onReserve;
  @override State<DiscoverScreen> createState()=>_DiscoverScreenState();
}
class _DiscoverScreenState extends State<DiscoverScreen>{
  String filter='All',search='';
  @override Widget build(BuildContext context){
    final shown=meals.where((m)=>m.qty>0&&(filter=='All'||m.kind==filter)&&('${m.name} ${m.cafe}'.toLowerCase().contains(search.toLowerCase()))).toList();
    return SafeArea(child:CustomScrollView(slivers:[
      SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.fromLTRB(20,18,20,12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(children:[const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text('FOODLOOP',style:TextStyle(color:green,fontSize:11,fontWeight:FontWeight.w800,letterSpacing:2)),
          SizedBox(height:5),Text('Good afternoon 👋',style:TextStyle(fontSize:25,fontWeight:FontWeight.w800)),
          SizedBox(height:3),Text('Find something good near you.',style:TextStyle(color:muted)),
        ])),Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:panel,borderRadius:BorderRadius.circular(15)),child:const Icon(Icons.notifications_none,color:green))]),
        const SizedBox(height:19),Container(padding:const EdgeInsets.all(17),decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xFF1D4A34),Color(0xFF173326)]),borderRadius:BorderRadius.circular(20)),child:const Row(children:[
          Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text('A little less waste.',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
            SizedBox(height:5),Text('A little more good.',style:TextStyle(color:Color(0xFFC2EBD1))),
            SizedBox(height:8),Text('Browse approved campus food offers',style:TextStyle(color:Colors.white70,fontSize:12)),
          ])),Icon(Icons.eco_rounded,size:48,color:green),
        ])),
        const SizedBox(height:18),TextField(onChanged:(v)=>setState(()=>search=v),decoration:const InputDecoration(prefixIcon:Icon(Icons.search),hintText:'Search meals or cafeterias')),
        const SizedBox(height:12),SingleChildScrollView(scrollDirection:Axis.horizontal,child:Row(children:[
          for(final f in ['All','Vegetarian','Vegan','Non-vegetarian'])Padding(padding:const EdgeInsets.only(right:8),child:ChoiceChip(label:Text(f),selected:filter==f,selectedColor:green.withOpacity(.2),onSelected:(_)=>setState(()=>filter=f))),
        ])),
        const SizedBox(height:12),Row(children:[const Expanded(child:Text('Available near you',style:TextStyle(fontSize:19,fontWeight:FontWeight.bold))),Text('${shown.length} offers',style:const TextStyle(color:muted,fontSize:12))]),
      ]))),
      if(shown.isEmpty)const SliverToBoxAdapter(child:Padding(padding:EdgeInsets.all(30),child:Center(child:Text('No food offers match your search.',style:TextStyle(color:muted))))),
      SliverPadding(padding:const EdgeInsets.fromLTRB(20,8,20,24),sliver:SliverList(delegate:SliverChildBuilderDelegate((context,i){
        final m=shown[i];
        return Container(margin:const EdgeInsets.only(bottom:13),decoration:BoxDecoration(color:panel,borderRadius:BorderRadius.circular(19)),child:ListTile(
          contentPadding:const EdgeInsets.all(13),leading:Container(width:66,height:68,decoration:BoxDecoration(color:panel2,borderRadius:BorderRadius.circular(14)),child:const Icon(Icons.ramen_dining,color:green,size:34)),
          title:Text(m.name,style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Padding(padding:const EdgeInsets.only(top:6),child:Text('${m.cafe}\n${m.kind} · ${m.qty} left · By ${m.deadline}',style:const TextStyle(color:muted,height:1.5,fontSize:12))),
          trailing:const Icon(Icons.chevron_right,color:muted),onTap:()=>showModalBottomSheet(context:context,isScrollControlled:true,backgroundColor:panel,builder:(_)=>MealSheet(meal:m,onReserve:widget.onReserve)),
        ));
      },childCount:shown.length))),
    ]));
  }
}

class MealSheet extends StatefulWidget {
  const MealSheet({super.key,required this.meal,required this.onReserve}); final Meal meal; final void Function(Meal,int) onReserve;
  @override State<MealSheet> createState()=>_MealSheetState();
}
class _MealSheetState extends State<MealSheet>{
  int count=1;
  @override Widget build(BuildContext context)=>Padding(padding:EdgeInsets.fromLTRB(22,20,22,MediaQuery.of(context).viewInsets.bottom+25),child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
    Center(child:Container(width:42,height:4,decoration:BoxDecoration(color:muted,borderRadius:BorderRadius.circular(5)))),
    const SizedBox(height:20),Container(height:125,width:double.infinity,decoration:BoxDecoration(color:panel2,borderRadius:BorderRadius.circular(18)),child:const Icon(Icons.rice_bowl,color:green,size:70)),
    const SizedBox(height:17),Text(widget.meal.name,style:const TextStyle(fontSize:23,fontWeight:FontWeight.bold)),
    Text(widget.meal.cafe,style:const TextStyle(color:muted)),const SizedBox(height:15),
    _line(Icons.location_on_outlined,widget.meal.location),_line(Icons.schedule,'Collect by ${widget.meal.deadline}'),
    _line(Icons.restaurant_menu,widget.meal.kind),_line(Icons.info_outline,'Allergens: ${widget.meal.allergens}'),
    const SizedBox(height:10),Text(widget.meal.description,style:const TextStyle(color:muted,fontSize:13)),
    const SizedBox(height:14),Row(children:[const Expanded(child:Text('Portions')),IconButton(onPressed:count>1?()=>setState(()=>count--):null,icon:const Icon(Icons.remove_circle_outline)),Text('$count'),IconButton(onPressed:count<widget.meal.qty?()=>setState(()=>count++):null,icon:const Icon(Icons.add_circle_outline))]),
    SizedBox(width:double.infinity,height:52,child:FilledButton(onPressed:widget.meal.qty>=count?(){Navigator.pop(context);widget.onReserve(widget.meal,count);}:null,style:FilledButton.styleFrom(backgroundColor:green,foregroundColor:bg),child:const Text('Reserve food'))),
  ]));
  Widget _line(IconData i,String t)=>Padding(padding:const EdgeInsets.only(bottom:9),child:Row(children:[Icon(i,color:green,size:18),const SizedBox(width:9),Expanded(child:Text(t,style:const TextStyle(color:Colors.white70,fontSize:13)))]));
}

class PickupsScreen extends StatelessWidget {
  const PickupsScreen({super.key, required this.pickups, required this.onCollected});

  final List<Pickup> pickups;
  final void Function(Pickup) onCollected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My pickups', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            const Text('Your reserved campus food.', style: TextStyle(color: muted)),
            const SizedBox(height: 20),
            if (pickups.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.confirmation_number_outlined, size: 55, color: muted),
                      SizedBox(height: 12),
                      Text('No reservations yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('Your confirmed pickups will appear here.', style: TextStyle(color: muted)),
                    ],
                  ),
                ),
              ),
            if (pickups.isNotEmpty)
              Expanded(
                child: ListView(
                  children: [
                    for (final p in pickups)
                      Container(
                        margin: const EdgeInsets.only(bottom: 13),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(18)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.check_circle, color: green),
                                const SizedBox(width: 8),
                                Expanded(child: Text(p.meal.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                                Text(p.collected ? 'Collected' : 'Reserved', style: const TextStyle(color: green)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('${p.count} portion(s) · ${p.meal.cafe}', style: const TextStyle(color: muted, fontSize: 12)),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(13),
                              decoration: BoxDecoration(color: panel2, borderRadius: BorderRadius.circular(13)),
                              child: Column(
                                children: [
                                  const Icon(Icons.qr_code_2, size: 55, color: green),
                                  Text(p.code, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                                  const Text('Demo code · not a scannable QR credential', style: TextStyle(color: muted, fontSize: 10)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 9),
                            Text('${p.meal.location} · By ${p.meal.deadline}', style: const TextStyle(color: muted, fontSize: 12)),
                            if (!p.collected)
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Only authorised cafeteria staff can confirm real collection.')),
                                  ),
                                  child: const Text('Collection pending staff verification'),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ImpactScreen extends StatelessWidget {
  const ImpactScreen({super.key,required this.pickups}); final List<Pickup> pickups;
  @override Widget build(BuildContext context){
    final collected=pickups.where((p)=>p.collected).fold<int>(0,(n,p)=>n+p.count);
    final reserved=pickups.where((p)=>!p.collected).fold<int>(0,(n,p)=>n+p.count);
    return SafeArea(child:ListView(padding:const EdgeInsets.all(20),children:[
      const Text('My impact',style:TextStyle(fontSize:27,fontWeight:FontWeight.w800)),const SizedBox(height:5),const Text('Small actions make a difference.',style:TextStyle(color:muted)),const SizedBox(height:22),
      Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xFF1D4A34),Color(0xFF173326)]),borderRadius:BorderRadius.circular(22)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Icon(Icons.eco,color:green,size:34),const SizedBox(height:15),Text('$collected',style:const TextStyle(fontSize:42,fontWeight:FontWeight.w900)),const Text('portions collected by you',style:TextStyle(color:Colors.white70))])),
      const SizedBox(height:15),Row(children:[Expanded(child:_metric('Reserved','$reserved',Icons.bookmark_outline)),const SizedBox(width:12),Expanded(child:_metric('Collected','$collected',Icons.check_circle_outline))]),
      const SizedBox(height:20),const Text('Impact counts update only after authorised collection confirmation.',style:TextStyle(color:muted,fontSize:12)),
    ]));
  }
  Widget _metric(String t,String v,IconData i)=>Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:panel,borderRadius:BorderRadius.circular(16)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(i,color:green),const SizedBox(height:8),Text(v,style:const TextStyle(fontSize:24,fontWeight:FontWeight.bold)),Text(t,style:const TextStyle(color:muted))]));
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key,required this.email,required this.onLogout}); final String email; final VoidCallback onLogout;
  @override Widget build(BuildContext context)=>SafeArea(child:ListView(padding:const EdgeInsets.all(20),children:[
    const Text('Profile',style:TextStyle(fontSize:27,fontWeight:FontWeight.w800)),const SizedBox(height:20),
    Container(padding:const EdgeInsets.all(17),decoration:BoxDecoration(color:panel,borderRadius:BorderRadius.circular(18)),child:Row(children:[const CircleAvatar(backgroundColor:panel2,child:Icon(Icons.person,color:green)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(email.split('@').first,style:const TextStyle(fontWeight:FontWeight.bold)),Text(email,style:const TextStyle(color:muted,fontSize:12)),const Text('Demo account · verification pending',style:TextStyle(color:green,fontSize:10))]))])),
    const SizedBox(height:15),const ListTile(leading:Icon(Icons.school_outlined,color:green),title:Text('College account'),subtitle:Text('Email verification will be connected with Firebase')),
    const ListTile(leading:Icon(Icons.notifications_outlined,color:green),title:Text('Notifications'),subtitle:Text('Food availability and pickup updates')),
    const ListTile(leading:Icon(Icons.privacy_tip_outlined,color:green),title:Text('Privacy & safety')),
    OutlinedButton.icon(onPressed:onLogout,icon:const Icon(Icons.logout),label:const Text('Sign out')),
  ]));
}

class CafeteriaScreen extends StatefulWidget {
  const CafeteriaScreen({super.key,required this.email}); final String email;
  @override State<CafeteriaScreen> createState()=>_CafeteriaScreenState();
}
class _CafeteriaScreenState extends State<CafeteriaScreen>{
  final item=TextEditingController(),qty=TextEditingController(),deadline=TextEditingController(text:'2:30 PM');
  String category='Vegetarian';

  @override
  void dispose() {
    item.dispose();
    qty.dispose();
    deadline.dispose();
    super.dispose();
  }

  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('FoodLoop · Cafeteria'),actions:[IconButton(onPressed:()=>Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder:(_)=>const LoginScreen()),(r)=>false),icon:const Icon(Icons.logout))]),body:ListView(padding:const EdgeInsets.all(20),children:[
    const Text('Surplus food',style:TextStyle(fontSize:26,fontWeight:FontWeight.w800)),const SizedBox(height:5),const Text('Register food for campus collection.',style:TextStyle(color:muted)),const SizedBox(height:20),
    TextField(controller:item,decoration:const InputDecoration(labelText:'Food item name',hintText:'e.g. Vegetable rice')),const SizedBox(height:12),
    TextField(controller:qty,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Available portions')),const SizedBox(height:12),
    TextField(controller:deadline,decoration:const InputDecoration(labelText:'Collection deadline')),const SizedBox(height:12),
    DropdownButtonFormField<String>(value:category,decoration:const InputDecoration(labelText:'Dietary category'),items:['Vegetarian','Vegan','Non-vegetarian'].map((s)=>DropdownMenuItem(value:s,child:Text(s))).toList(),onChanged:(v)=>setState(()=>category=v??'Vegetarian')),
    const SizedBox(height:15),Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:panel,borderRadius:BorderRadius.circular(14)),child:const Text('Food safety and allergen details must be verified by an authorised operator before a listing is visible to students.',style:TextStyle(color:muted,fontSize:12))),
    const SizedBox(height:18),FilledButton(onPressed:()=>ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Demo screen only. Firebase will publish approved listings across devices.'))),style:FilledButton.styleFrom(backgroundColor:green,foregroundColor:bg,padding:const EdgeInsets.all(15)),child:const Text('Save food batch')),
  ]));
}


// ADMIN DASHBOARD: offline demo integration of the forecasting and sensor-quality engine.
// Replace this file together with foodloop_engine.dart in lib/.
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key, required this.email});
  final String email;
  @override State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _engine = const FoodLoopForecastEngine();
  final _sales = TextEditingController(text: '42');
  final _elapsed = TextEditingController(text: '90');
  final _remaining = TextEditingController(text: '90');
  final _prepared = TextEditingController(text: '35');
  final _stock = TextEditingController(text: '30');
  final _footfall = TextEditingController(text: '55');
  final _occupancy = TextEditingController(text: '0.85');
  final _event = TextEditingController(text: '1.0');
  final _itemId = TextEditingController(text: 'rice');
  bool _festival = false, _holiday = false, _exam = false, _breakPeriod = false;
  RainLevel _rain = RainLevel.none;
  DemandForecast? _result;
  SensorCheck? _sensorResult;

  List<SalesObservation> _history() {
    final now = DateTime.now();
    final rows = <SalesObservation>[];
    // Deterministic sample data for a working demo. Replace with campus POS history.
    for (var i = 1; i <= 56; i++) {
      final d = now.subtract(Duration(days: i));
      final weekdayBias = d.weekday >= 1 && d.weekday <= 5 ? 1.0 : 0.78;
      final monthBias = d.month == now.month ? 1.05 : 1.0;
      final sold = (42 * weekdayBias * monthBias + ((i * 7) % 11) - 5).round().clamp(8, 70).toInt();
      rows.add(SalesObservation(date: d, itemId: 'rice', sold: sold,
          prepared: sold + 8, stockout: false));
    }
    return rows;
  }

  int _int(TextEditingController c, int fallback) =>
      int.tryParse(c.text.trim()) ?? fallback;
  double _double(TextEditingController c, double fallback) =>
      double.tryParse(c.text.trim()) ?? fallback;

  void _runForecast() {
    final now = DateTime.now();
    final occupancy = _double(_occupancy, 0.85).clamp(0.2, 1.0).toDouble();
    final event = _double(_event, 1.0).clamp(0.7, 1.6).toDouble();
    final result = _engine.forecast(
      itemId: 'rice',
      targetDate: now,
      history: _history(),
      calendar: LocalCalendarDay(date: now, isFestival: _festival,
        isHoliday: _holiday, isExamPeriod: _exam,
        isSemesterBreak: _breakPeriod, hostelOccupancy: occupancy,
        campusEventMultiplier: event),
      rain: _rain,
      alreadyPrepared: _int(_prepared, 35),
      availableUncookedStock: _int(_stock, 30),
      live: LiveDemandSignal(
        soldSoFar: _int(_sales, 42),
        minutesElapsed: _int(_elapsed, 90),
        minutesRemaining: _int(_remaining, 90),
        preparedSoFar: _int(_prepared, 35),
        footfallSoFar: _int(_footfall, 55),
      ),
    );
    setState(() => _result = result);
  }

  void _runSensorCheck() {
    final now = DateTime.now();
    final reading = SensorReading(sensorId: 'DEMO-01', metric: 'temperature',
      value: 31.5, recordedAt: now, sequenceId: 'DEMO-${now.millisecondsSinceEpoch}');
    final result = const SensorQualityGuard().validate(
      reading: reading, now: now, minValue: -5, maxValue: 60,
      seenSequenceIds: <String>{},
      previous: SensorReading(sensorId: 'DEMO-01', metric: 'temperature',
        value: 30.8, recordedAt: now.subtract(const Duration(minutes: 1)),
        sequenceId: 'DEMO-PREV'),
      maxChangePerMinute: 5,
    );
    setState(() => _sensorResult = result);
  }

  @override
  void dispose() {
    for (final c in [_sales, _elapsed, _remaining, _prepared, _stock,
      _footfall, _occupancy, _event, _itemId]) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('FoodLoop · Admin dashboard'),
      actions: [IconButton(tooltip: 'Sign out', onPressed: () =>
        Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false),
        icon: const Icon(Icons.logout))]),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      const Text('Demand intelligence', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
      const SizedBox(height: 5),
      const Text('Forecast portions, account for campus conditions and flag data-quality issues.',
        style: TextStyle(color: muted)),
      const SizedBox(height: 16),
      _section('LIVE SALES INPUTS', [
        _field(_sales, 'Sold so far (portions)', number: true),
        _field(_elapsed, 'Minutes elapsed', number: true),
        _field(_remaining, 'Minutes remaining', number: true),
        _field(_footfall, 'Footfall so far (people)', number: true),
        _field(_prepared, 'Already prepared (portions)', number: true),
        _field(_stock, 'Uncooked stock available (portions)', number: true),
      ]),
      _section('CAMPUS CONDITIONS', [
        _field(_occupancy, 'Hostel occupancy (0.20 to 1.00)'),
        _field(_event, 'Campus event multiplier (0.70 to 1.60)'),
        DropdownButtonFormField<RainLevel>(
          value: _rain, decoration: const InputDecoration(labelText: 'Rain condition'),
          items: RainLevel.values.map((r) => DropdownMenuItem(value: r,
            child: Text(r.name.toUpperCase()))).toList(),
          onChanged: (v) => setState(() => _rain = v ?? RainLevel.none)),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Festival day'), value: _festival,
          onChanged: (v) => setState(() => _festival = v)),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Public / campus holiday'), value: _holiday,
          onChanged: (v) => setState(() => _holiday = v)),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Exam period'), value: _exam,
          onChanged: (v) => setState(() => _exam = v)),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Semester break'), value: _breakPeriod,
          onChanged: (v) => setState(() => _breakPeriod = v)),
      ]),
      SizedBox(height: 50, child: FilledButton.icon(
        onPressed: _runForecast, icon: const Icon(Icons.auto_graph),
        style: FilledButton.styleFrom(backgroundColor: green, foregroundColor: bg),
        label: const Text('RUN DEMAND FORECAST'))),
      if (_result != null) ...[
        const SizedBox(height: 18),
        _resultCard(_result!),
      ],
      const SizedBox(height: 20),
      _section('SENSOR DATA QUALITY · CONSTRAINT 10', [
        const Text('Checks for missing, stale, duplicate, out-of-range, spike and conflicting readings.',
          style: TextStyle(color: muted, fontSize: 12)),
        OutlinedButton.icon(onPressed: _runSensorCheck,
          icon: const Icon(Icons.verified_user_outlined),
          label: const Text('Run sample sensor validation')),
        if (_sensorResult != null)
          ListTile(contentPadding: EdgeInsets.zero,
            leading: Icon(_sensorResult!.usable ? Icons.check_circle : Icons.warning,
              color: _sensorResult!.usable ? green : Colors.orange),
            title: Text(_sensorResult!.status.name.toUpperCase()),
            subtitle: Text(_sensorResult!.message)),
      ]),
      const SizedBox(height: 12),
      const Text('DEMO DATA NOTICE: Historical sales and sensor values in this prototype are simulated. Replace them with verified cafeteria records and calibrated sensors before operational use.',
        style: TextStyle(color: muted, fontSize: 11)),
    ]),
  );

  Widget _section(String title, List<Widget> children) => Container(
    margin: const EdgeInsets.only(bottom: 15), padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(17)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: green, fontSize: 11,
        letterSpacing: 1.2, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12), ...children,
    ]),
  );

  Widget _field(TextEditingController c, String label, {bool number = false}) =>
    Padding(padding: const EdgeInsets.only(bottom: 10),
      child: TextField(controller: c, keyboardType: number
        ? TextInputType.number : const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label)));

  Widget _resultCard(DemandForecast r) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(color: panel2, borderRadius: BorderRadius.circular(18)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('FORECAST RESULT', style: TextStyle(color: green, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _metric('Expected demand', '${r.recommendedDemand}')),
        const SizedBox(width: 8),
        Expanded(child: _metric('Prepare', '${r.recommendedPreparation}')),
      ]),
      const SizedBox(height: 8),
      _metric('Additional preparation needed', '${r.extraToPrepare} portions'),
      if (r.surgeDetected) ...[
        const SizedBox(height: 12),
        const Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 8), Expanded(child: Text('SURGE ALERT · Live demand is elevated.',
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)))]),
      ],
      const Divider(height: 24),
      Text('Baseline: ${r.baseline}  ·  Weekday factor: ${r.dayFactor.toStringAsFixed(2)}  ·  Month factor: ${r.monthFactor.toStringAsFixed(2)}'),
      Text('Occupancy: ${r.occupancyFactor.toStringAsFixed(2)}  ·  Rain: ${r.rainFactor.toStringAsFixed(2)}  ·  Event: ${r.eventFactor.toStringAsFixed(2)}'),
      const SizedBox(height: 10),
      for (final line in r.explanation) Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Text('• $line', style: const TextStyle(color: muted, fontSize: 12))),
    ]),
  );

  Widget _metric(String label, String value) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
      Text(label, style: const TextStyle(color: muted, fontSize: 11)),
    ]),
  );
}

