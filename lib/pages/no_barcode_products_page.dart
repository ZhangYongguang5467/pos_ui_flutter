import 'package:flutter/material.dart';

class NoBarcodeProductsPage extends StatefulWidget {
  const NoBarcodeProductsPage({super.key});

  @override
  State<NoBarcodeProductsPage> createState() => _NoBarcodeProductsPageState();
}

class _NoBarcodeProductsPageState extends State<NoBarcodeProductsPage> {
  String selectedCategory = 'やさい';

  // JSON product data
  final Map<String, List<Map<String, dynamic>>> productData = {
    'やさい': [
      {
        'name': 'ブロッコリー',
        'price': 1,
        'image': 'broccoli',
        'color': Colors.green[800],
      },
      {
        'name': 'トマト１玉',
        'price': 1,
        'image': 'tomato',
        'color': Colors.red[600],
      },
      {
        'name': 'キャベツ１玉',
        'price': 1,
        'image': 'cabbage',
        'color': Colors.green[300],
      },
      {
        'name': 'パプリカ赤・黄',
        'price': 1,
        'image': 'paprika',
        'color': Colors.orange[600],
      },
      {
        'name': '白菜 １/４',
        'price': 1,
        'image': 'chinese_cabbage',
        'color': Colors.yellow[100],
      },
      {
        'name': '大根１本',
        'price': 1,
        'image': 'daikon',
        'color': Colors.grey[100],
      },
      {
        'name': '白ねぎ１束',
        'price': 1,
        'image': 'leek',
        'color': Colors.green[200],
      },
      {
        'name': 'アスパラ',
        'price': 1,
        'image': 'asparagus',
        'color': Colors.green[400],
      },
      {
        'name': 'ゴーヤ',
        'price': 1,
        'image': 'goya',
        'color': Colors.green[600],
      },
      {
        'name': '白菜１玉',
        'price': 0,
        'image': 'placeholder',
        'color': Colors.grey[300],
      },
      {
        'name': '胡瓜１本',
        'price': 1,
        'image': 'cucumber',
        'color': Colors.green[500],
      },
      {
        'name': 'アボカド',
        'price': 1,
        'image': 'avocado',
        'color': Colors.green[700],
      },
    ],
    'そうざい': [
      {
        'name': '赤兎馬 梅酒',
        'price': 2997,
        'image': 'alcohol',
        'color': Colors.amber[200],
      },
      {
        'name': '小花柄シャツ',
        'price': 782,
        'image': 'shirt',
        'color': Colors.pink[100],
      },
      {
        'name': '田舎わっぱ飯',
        'price': 498,
        'image': 'bento',
        'color': Colors.brown[200],
      },
      {
        'name': '和風弁当',
        'price': 380,
        'image': 'bento2',
        'color': Colors.orange[200],
      },
    ],
    'くだもの': [
      // Add fruit items here
    ],
    'さかな': [
      // Add fish items here
    ],
    '食品・飲料': [
      {
        'name': '婦人シューズ ST1115',
        'price': 1565,
        'image': 'shoes',
        'color': Colors.brown[400],
      },
    ],
    'おでん': [
      // Add oden items here
    ],
    '手入力': [
      // Add manual input items here
    ],
  };

  List<String> get categories => productData.keys.toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Top navigation bar
          Container(
            height: 80,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Back button
                Container(
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A6FA5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(8),
                      child: const Center(
                        child: Text(
                          '戻る',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Staff call button
                Container(
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Handle staff call
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: const Center(
                        child: Text(
                          '係員呼出',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Title
                const Text(
                  'バーコードがない商品',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Trial badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'TRIAL',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Main content
          Expanded(
            child: Row(
              children: [
                // Left sidebar - Categories
                Container(
                  width: 200,
                  color: const Color(0xFF4A6FA5),
                  child: Column(
                    children: categories.map((category) {
                      final isSelected = category == selectedCategory;
                      return Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF6B9BD8) : null,
                          border: const Border(
                            bottom: BorderSide(color: Colors.white24, width: 1),
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedCategory = category;
                              });
                            },
                            child: Center(
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                
                // Right content - Product grid
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Scroll indicator
                        if (productData[selectedCategory]!.length > 8)
                          Container(
                            height: 40,
                            alignment: Alignment.centerRight,
                            child: Column(
                              children: [
                                Icon(Icons.keyboard_arrow_up, color: Colors.grey[600]),
                                Text(
                                  '1/2',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                              ],
                            ),
                          ),
                        
                        // Product grid
                        Expanded(
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                            ),
                            itemCount: productData[selectedCategory]!.length,
                            itemBuilder: (context, index) {
                              final product = productData[selectedCategory]![index];
                              return _buildProductCard(product);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Handle product selection
            _selectProduct(product);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Product name
                Text(
                  product['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                // Price
                Text(
                  '${product['price']}円',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Product image/icon placeholder
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: product['color'] ?? Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _getProductIcon(product['image']),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getProductIcon(String imageName) {
    switch (imageName) {
      case 'broccoli':
        return Icon(Icons.eco, size: 40, color: Colors.green[900]);
      case 'tomato':
        return Icon(Icons.circle, size: 40, color: Colors.red[800]);
      case 'cabbage':
        return Icon(Icons.grass, size: 40, color: Colors.green[700]);
      case 'paprika':
        return Icon(Icons.local_florist, size: 40, color: Colors.orange[800]);
      case 'chinese_cabbage':
        return Icon(Icons.eco, size: 40, color: Colors.green[600]);
      case 'daikon':
        return Icon(Icons.straighten, size: 40, color: Colors.grey[700]);
      case 'leek':
        return Icon(Icons.grass, size: 40, color: Colors.green[500]);
      case 'asparagus':
        return Icon(Icons.local_florist, size: 40, color: Colors.green[700]);
      case 'goya':
        return Icon(Icons.eco, size: 40, color: Colors.green[800]);
      case 'cucumber':
        return Icon(Icons.straighten, size: 40, color: Colors.green[600]);
      case 'avocado':
        return Icon(Icons.circle, size: 40, color: Colors.green[900]);
      case 'placeholder':
        return Icon(Icons.close, size: 40, color: Colors.grey[600]);
      default:
        return Icon(Icons.shopping_basket, size: 40, color: Colors.grey[600]);
    }
  }

  void _selectProduct(Map<String, dynamic> product) {
    // Return the selected product to the shopping page
    Navigator.pop(context, product);
  }
} 