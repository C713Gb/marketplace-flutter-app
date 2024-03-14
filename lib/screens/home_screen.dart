import 'package:flutter/material.dart';
import 'package:marketplace_flutter/models/product.dart';
import 'package:marketplace_flutter/screens/login_screen.dart';
import 'package:marketplace_flutter/services/auth_service.dart';
import 'package:marketplace_flutter/services/user_service.dart';
import '../services/api_service.dart';
import '../widgets/product_title.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Product>> _futureProducts;
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _futureProducts = ApiService().fetchProducts();
    _updateCurrentUser();
  }

  void _updateCurrentUser() async {
    final token = await _authService.getToken();
    if (token != null) {
      final currentUser = await _userService.getCurrentUser(token);
      if (currentUser != null) {
        await _authService.saveCurrentUser(currentUser.id, currentUser.username);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MarketPlace'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _futureProducts,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ProductTitle(product: snapshot.data![index]);
              },
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }

  void _logout(BuildContext context) async {
    await _authService.logout();
    // Navigate back to the LoginScreen and remove all routes behind
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }
}
