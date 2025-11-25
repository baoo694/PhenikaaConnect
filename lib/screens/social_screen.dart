import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';
import '../models/post.dart';
import 'comments_screen.dart';
import 'post_detail_screen.dart';
import 'image_viewer_screen.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

enum _PostFilter { all, mine }

class _SocialScreenState extends State<SocialScreen> {
  final TextEditingController _postController = TextEditingController();
  String? _selectedImageBase64;
  final Set<String> _expandedPosts = {};
  _PostFilter _selectedFilter = _PostFilter.all;

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
      ),
      body: _buildFeedTab(),
    );
  }

  Widget _buildFeedTab() {
    return RefreshIndicator(
      onRefresh: () =>
          context.read<AppProvider>().loadPosts(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCreatePostCard(),
            const SizedBox(height: 16),
            _buildFilterChips(),
            const SizedBox(height: 16),
            _buildPostsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatePostCard() {
    return CustomCard(
      child: InkWell(
        onTap: () => _showCreatePostModal(),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Consumer<AppProvider>(
                builder: (context, appProvider, child) {
                  final userName = appProvider.currentUser?.name ?? 'Bạn';
                  return CustomAvatar(
                    initials: userName.isNotEmpty ? userName[0] : 'B',
                    radius: 20,
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'Bạn đang nghĩ gì?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostsList() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        if (appProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        final currentUserId = appProvider.currentUser?.id;
        List<Post> filteredPosts = appProvider.posts;
        if (_selectedFilter == _PostFilter.mine && currentUserId != null) {
          filteredPosts =
              filteredPosts.where((post) => post.userId == currentUserId).toList();
        }

        if (filteredPosts.isEmpty) {
          final emptyText = _selectedFilter == _PostFilter.mine
              ? 'Bạn chưa có bài viết nào'
              : 'Chưa có bài đăng nào';
          return Center(
            child: Text(emptyText),
          );
        }
        
        return Column(
          children: filteredPosts.map((post) => _buildPostCard(post)).toList(),
        );
      },
    );
  }

  Widget _buildFilterChips() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final canUseMyPosts = appProvider.currentUser != null;
        final theme = Theme.of(context);

        Widget buildChip(String label, _PostFilter value,
            {required bool enabled, IconData? icon}) {
          final isSelected = _selectedFilter == value;
          final bgColor = isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.colorScheme.surfaceVariant.withOpacity(0.4);
          final fgColor =
              isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface;
          return Expanded(
            child: GestureDetector(
              onTap: enabled
                  ? () {
                      setState(() {
                        _selectedFilter = value;
                      });
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: enabled ? bgColor : bgColor.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: 18,
                        color: enabled ? fgColor : fgColor.withOpacity(0.5),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: enabled ? fgColor : fgColor.withOpacity(0.5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Row(
          children: [
            buildChip('Tất cả', _PostFilter.all, enabled: true, icon: LucideIcons.list),
            const SizedBox(width: 8),
            buildChip(
              'Bài viết của tôi',
              _PostFilter.mine,
              enabled: canUseMyPosts,
              icon: LucideIcons.user,
            ),
          ],
        );
      },
    );
  }

  Widget _buildPostCard(dynamic post) {
    final postId = post.id.toString();
    final isExpanded = _expandedPosts.contains(postId);
    final contentText = post.content ?? '';

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: () => _openPostDetail(post),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomAvatar(
                initials: post.avatar,
                radius: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.author,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '${post.major} • ${post.time}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              ),
              Consumer<AppProvider>(
                builder: (context, appProvider, child) {
                  final currentUserId = appProvider.currentUser?.id;
                  final isOwner = post.userId != null && post.userId == currentUserId;
                  
                  if (!isOwner) {
                    return const SizedBox.shrink();
                  }
                  
                  return PopupMenuButton<String>(
                    icon: const Icon(
                      LucideIcons.moreVertical,
                      size: 20,
                      color: Colors.grey,
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditPostModal(post);
                      } else if (value == 'delete') {
                        _confirmDeletePost(post);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(LucideIcons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Sửa bài đăng'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(LucideIcons.trash2, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Xóa bài đăng', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ImageViewerScreen(
                      imageUrl: post.imageUrl!,
                      title: 'Ảnh bài viết',
                    ),
                  ),
                );
              },
              behavior: HitTestBehavior.opaque,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Stack(
                    children: [
                      Image.network(
                        post.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          alignment: Alignment.center,
                          child: const Icon(LucideIcons.imageOff, color: Colors.grey),
                        ),
                      ),
                      // Overlay để hiển thị icon zoom
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            LucideIcons.maximize2,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          _ExpandableText(
            text: contentText,
            postId: postId,
            isExpanded: isExpanded,
            onExpand: () {
              setState(() {
                _expandedPosts.add(postId);
              });
            },
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Consumer<AppProvider>(
                builder: (context, appProvider, child) {
                  return GestureDetector(
                    onTap: () => appProvider.togglePostLike(post.id),
                    child: Row(
                      children: [
                        Icon(
                          post.liked ? LucideIcons.heart : LucideIcons.heart,
                          size: 20,
                          color: post.liked ? Colors.red : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${post.likes}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                },
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      if (!mounted) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CommentsScreen(post: post),
                        ),
                      );
                    },
                    child: const Icon(
                      LucideIcons.messageSquare,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${post.comments}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openPostDetail(dynamic post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(post: post),
      ),
    );
  }

  void _showCreatePostModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            height: MediaQuery.of(ctx).size.height * 0.75,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: _CreatePostModalContent(
              initialImage: _selectedImageBase64,
              onPostCreated: () {
                setState(() {
                  _selectedImageBase64 = null;
                });
              },
            ),
          ),
        );
      },
    );
  }

  void _showEditPostModal(dynamic post) {
    final TextEditingController editController = TextEditingController(text: post.content);
    String? editSelectedImage = post.imageUrl;
    // Save parent context for use after modal closes
    final parentContext = context;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            height: MediaQuery.of(ctx).size.height * 0.75,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: StatefulBuilder(
              builder: (context, modalSetState) {
                String? modalSelectedImage = editSelectedImage;
                bool isSubmitting = false;

                Future<void> submitEdit() async {
                  final text = editController.text.trim();
                  if (text.isEmpty) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vui lòng nhập nội dung bài viết'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  if (!context.mounted) return;
                  modalSetState(() => isSubmitting = true);
                  final appProvider = Provider.of<AppProvider>(context, listen: false);
                  
                  // Check if image was removed (was URL, now null)
                  final hadImage = post.imageUrl != null && post.imageUrl!.isNotEmpty;
                  final hasImage = modalSelectedImage != null;
                  final imageRemoved = hadImage && !hasImage;
                  
                  // If image is base64 (new image), send it. If it's a URL (existing), don't send it
                  String? imageBase64;
                  final selectedImage = modalSelectedImage;
                  if (selectedImage != null) {
                    // Check if it's a new base64 image or existing URL
                    if (!selectedImage.startsWith('http') && 
                        !selectedImage.startsWith('https')) {
                      // It's a new base64 image
                      imageBase64 = selectedImage;
                    }
                    // If it's a URL, we don't need to send it (image stays the same)
                  }
                  
                  final ok = await appProvider.updatePost(
                    post.id,
                    text,
                    imageBase64: imageBase64,
                    removeImage: imageRemoved,
                  );
                  
                  // Check if modal is still mounted before any UI operations
                  if (!context.mounted) return;
                  
                  // Update submitting state
                  modalSetState(() => isSubmitting = false);

                  if (ok) {
                    // Close modal first before showing success message
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      // Use parent context for snackbar after modal closes
                      if (parentContext.mounted) {
                        ScaffoldMessenger.of(parentContext).showSnackBar(
                          const SnackBar(
                            content: Text('Cập nhật bài viết thành công'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  } else {
                    // Show error in modal context (modal is still open)
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cập nhật bài viết thất bại'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }

                return Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sửa bài viết',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    // Body
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // User info
                            Consumer<AppProvider>(
                              builder: (context, appProvider, child) {
                                final userName = appProvider.currentUser?.name ?? 'Bạn';
                                final userMajor = appProvider.currentUser?.major ?? '';
                                return Row(
                                  children: [
                                    CustomAvatar(
                                      initials: userName.isNotEmpty ? userName[0] : 'B',
                                      radius: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          userName,
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (userMajor.isNotEmpty)
                                          Text(
                                            userMajor,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            // Content input
                            TextField(
                              controller: editController,
                              maxLines: 8,
                              autofocus: true,
                              decoration: InputDecoration(
                                hintText: 'Bạn đang nghĩ gì?',
                                border: InputBorder.none,
                                hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                                ),
                              ),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            // Image preview
                            if (modalSelectedImage != null) ...[
                              const SizedBox(height: 16),
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: modalSelectedImage!.startsWith('http')
                                        ? Image.network(
                                            modalSelectedImage!,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.memory(
                                            base64Decode(modalSelectedImage!),
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: IconButton(
                                      icon: const Icon(Icons.close, color: Colors.white),
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.black.withOpacity(0.5),
                                      ),
                                      onPressed: () {
                                        modalSetState(() {
                                          modalSelectedImage = null;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    // Footer actions
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  text: 'Ảnh',
                                  type: ButtonType.ghost,
                                  size: ButtonSize.small,
                                  icon: LucideIcons.image,
                                  onPressed: () async {
                                    final result = await FilePicker.platform.pickFiles(
                                      type: FileType.image,
                                      withData: true,
                                    );
                                    if (result != null && result.files.isNotEmpty) {
                                      final bytes = result.files.first.bytes;
                                      if (bytes != null) {
                                        final base64Image = base64Encode(bytes);
                                        modalSetState(() {
                                          modalSelectedImage = base64Image;
                                        });
                                      }
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: CustomButton(
                                  text: 'Cảm xúc',
                                  type: ButtonType.ghost,
                                  size: ButtonSize.small,
                                  icon: LucideIcons.smile,
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              text: 'Cập nhật',
                              icon: LucideIcons.save,
                              onPressed: isSubmitting ? null : submitEdit,
                              isLoading: isSubmitting,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _confirmDeletePost(dynamic post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa bài đăng'),
        content: const Text('Bạn có chắc chắn muốn xóa bài đăng này? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final appProvider = Provider.of<AppProvider>(context, listen: false);
              final success = await appProvider.deletePost(post.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'Đã xóa bài đăng' : 'Xóa bài đăng thất bại',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

// Widget to automatically detect and handle text truncation
class _ExpandableText extends StatelessWidget {
  final String text;
  final String postId;
  final bool isExpanded;
  final VoidCallback onExpand;

  const _ExpandableText({
    required this.text,
    required this.postId,
    required this.isExpanded,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          height: 1.5,
        ) ?? const TextStyle();

    // If expanded, show full text
    if (isExpanded) {
      return Text(
        text,
        style: textStyle,
      );
    }

    // Use a character threshold: if text is longer than 100 chars, show "Xem thêm"
    // This is a simple and reliable approach that ensures "Xem thêm" appears for long posts
    const int charThreshold = 100;
    
    if (text.length <= charThreshold) {
      return Text(
        text,
        style: textStyle,
      );
    }

    // Text is long - truncate and show "Xem thêm"
    // Find a good break point around the threshold
    int breakPoint = charThreshold;
    
    // Look backwards for a space or punctuation (up to 30 chars back)
    final searchStart = (breakPoint - 30).clamp(0, text.length);
    bool foundBreak = false;
    for (int i = breakPoint; i >= searchStart && i > 0; i--) {
      final char = text[i];
      if (char == ' ' || char == '.' || char == '!' || char == '?' || char == '\n' || char == ',') {
        breakPoint = i + 1;
        foundBreak = true;
        break;
      }
    }
    
    // If no good break point found, try to find any space
    if (!foundBreak) {
      for (int i = breakPoint; i >= (breakPoint - 20).clamp(0, text.length) && i > 0; i--) {
        if (text[i] == ' ') {
          breakPoint = i + 1;
          break;
        }
      }
    }
    
    breakPoint = breakPoint.clamp(0, text.length);
    final truncatedText = text.substring(0, breakPoint);

    return Text.rich(
      maxLines: 4,
      overflow: TextOverflow.visible,
      TextSpan(
        style: textStyle,
        children: [
          TextSpan(text: truncatedText),
          const TextSpan(text: '... '),
          TextSpan(
            text: 'Xem thêm',
            style: textStyle.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = onExpand,
          ),
        ],
      ),
    );
  }
}

class _CreatePostModalContent extends StatefulWidget {
  final String? initialImage;
  final VoidCallback onPostCreated;

  const _CreatePostModalContent({
    required this.initialImage,
    required this.onPostCreated,
  });

  @override
  State<_CreatePostModalContent> createState() => _CreatePostModalContentState();
}

class _CreatePostModalContentState extends State<_CreatePostModalContent> {
  late final TextEditingController _postController;
  String? _selectedImageBase64;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _postController = TextEditingController();
    _selectedImageBase64 = widget.initialImage;
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    final text = _postController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập nội dung bài viết'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final ok = await appProvider.createPost(text, imageBase64: _selectedImageBase64);
    
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (ok) {
      widget.onPostCreated();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng bài thành công')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng bài thất bại'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tạo bài viết',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        // Body
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User info
                Consumer<AppProvider>(
                  builder: (context, appProvider, child) {
                    final userName = appProvider.currentUser?.name ?? 'Bạn';
                    final userMajor = appProvider.currentUser?.major ?? '';
                    return Row(
                      children: [
                        CustomAvatar(
                          initials: userName.isNotEmpty ? userName[0] : 'B',
                          radius: 24,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (userMajor.isNotEmpty)
                              Text(
                                userMajor,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Content input
                TextField(
                  controller: _postController,
                  maxLines: 8,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Bạn đang nghĩ gì?',
                    border: InputBorder.none,
                    hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                // Image preview
                if (_selectedImageBase64 != null) ...[
                  const SizedBox(height: 16),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          base64Decode(_selectedImageBase64!),
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withOpacity(0.5),
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedImageBase64 = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        // Footer actions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Ảnh',
                      type: ButtonType.ghost,
                      size: ButtonSize.small,
                      icon: LucideIcons.image,
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.image,
                          withData: true,
                        );
                        if (result != null && result.files.isNotEmpty) {
                          final bytes = result.files.first.bytes;
                          if (bytes != null) {
                            setState(() {
                              _selectedImageBase64 = base64Encode(bytes);
                            });
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomButton(
                      text: 'Cảm xúc',
                      type: ButtonType.ghost,
                      size: ButtonSize.small,
                      icon: LucideIcons.smile,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Đăng bài',
                  icon: LucideIcons.send,
                  onPressed: _isSubmitting ? null : _submitPost,
                  isLoading: _isSubmitting,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
