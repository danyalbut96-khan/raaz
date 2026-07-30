import 'package:flutter/material.dart';

class SkeletonLoadingScreen extends StatefulWidget {
  const SkeletonLoadingScreen({super.key});

  @override
  State<SkeletonLoadingScreen> createState() => _SkeletonLoadingScreenState();
}

class _SkeletonLoadingScreenState extends State<SkeletonLoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf9f9ff),
      appBar: AppBar(
        backgroundColor: const Color(0xFFf9f9ff).withOpacity(0.85),
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.security, color: Color(0xFF004ac6)),
            const SizedBox(width: 8),
            const Text(
              'RAAZ',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF004ac6),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _buildShimmer(40, 40, shape: BoxShape.circle),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return _buildSkeletonCard(index == 1); // Second card has an image placeholder
        },
      ),
    );
  }

  Widget _buildSkeletonCard(bool hasImage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFc3c6d7).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildShimmer(40, 40, shape: BoxShape.circle),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmer(96, 16),
                      const SizedBox(height: 4),
                      _buildShimmer(64, 12),
                    ],
                  ),
                ],
              ),
              _buildShimmer(24, 24),
            ],
          ),
          const SizedBox(height: 16),
          _buildShimmer(double.infinity, 16),
          const SizedBox(height: 8),
          _buildShimmer(double.infinity, 16),
          const SizedBox(height: 8),
          _buildShimmer(200, 16),
          
          if (hasImage) ...[
            const SizedBox(height: 16),
            _buildShimmer(double.infinity, 200),
          ],
          
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildShimmer(48, 24, borderRadius: 12),
                  const SizedBox(width: 24),
                  _buildShimmer(48, 24, borderRadius: 12),
                ],
              ),
              _buildShimmer(32, 32, shape: BoxShape.circle),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer(double width, double height, {BoxShape shape = BoxShape.rectangle, double borderRadius = 4}) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFFe9edff).withOpacity(_animation.value),
            shape: shape,
            borderRadius: shape == BoxShape.rectangle ? BorderRadius.circular(borderRadius) : null,
          ),
        );
      },
    );
  }
}
