import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/fishtrace_colors.dart';
import '../../../app/theme/fishtrace_dimensions.dart';
import '../cards/fishtrace_cards.dart';

class ImageAttachmentPicker extends StatelessWidget {
  const ImageAttachmentPicker({
    super.key,
    required this.images,
    required this.onCamera,
    required this.onGallery,
    required this.onRemove,
    this.multiple = true,
  });

  final List<XFile> images;
  final VoidCallback? onCamera;
  final VoidCallback? onGallery;
  final ValueChanged<XFile> onRemove;
  final bool multiple;

  @override
  Widget build(BuildContext context) => FishTraceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          multiple ? 'Photo attachments' : 'Photo attachment',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: FishTraceSpacing.sm),
        if (images.isNotEmpty)
          SizedBox(
            height: 78,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: FishTraceSpacing.xs),
              itemBuilder: (context, index) {
                final image = images[index];
                return Stack(
                  children: [
                    Semantics(
                      image: true,
                      label: 'Attachment ${index + 1}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          FishTraceRadii.control,
                        ),
                        child: Image.file(
                          File(image.path),
                          width: 78,
                          height: 78,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 78,
                            height: 78,
                            color: FishTraceColors.surfaceMuted,
                            child: const Icon(Icons.image_outlined),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Semantics(
                        button: true,
                        label: 'Remove attachment ${index + 1}',
                        child: InkResponse(
                          radius: 22,
                          onTap: () => onRemove(image),
                          child: SizedBox.square(
                            dimension: FishTraceSizes.touchTarget,
                            child: Center(
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: FishTraceColors.navy,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 17,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        if (images.isNotEmpty) const SizedBox(height: FishTraceSpacing.sm),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: (!multiple && images.isNotEmpty) ? null : onCamera,
                icon: const Icon(Icons.camera_alt_outlined, size: 18),
                label: const Text('Camera'),
              ),
            ),
            const SizedBox(width: FishTraceSpacing.xs),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: (!multiple && images.isNotEmpty) ? null : onGallery,
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                label: const Text('Gallery'),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class SignaturePad extends StatefulWidget {
  const SignaturePad({super.key, required this.onChanged, this.height = 150});

  final ValueChanged<bool> onChanged;
  final double height;

  @override
  State<SignaturePad> createState() => SignaturePadState();
}

class SignaturePadState extends State<SignaturePad> {
  final List<List<Offset>> _strokes = [];
  final _typedSignature = TextEditingController();

  bool get hasSignature =>
      _strokes.any((stroke) => stroke.length > 1) ||
      _typedSignature.text.trim().isNotEmpty;

  @override
  void dispose() {
    _typedSignature.dispose();
    super.dispose();
  }

  void clear() {
    setState(() {
      _strokes.clear();
      _typedSignature.clear();
    });
    widget.onChanged(false);
  }

  Future<ui.Image?> exportImage({double pixelRatio = 2}) async {
    if (!hasSignature) return null;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    _SignaturePainter(_strokes).paint(canvas, Size(390, widget.height));
    final typed = _typedSignature.text.trim();
    if (typed.isNotEmpty) {
      final paragraph =
          (ui.ParagraphBuilder(
              ui.ParagraphStyle(fontSize: 26, fontStyle: FontStyle.italic),
            )..addText(typed)).build()
            ..layout(const ui.ParagraphConstraints(width: 358));
      canvas.drawParagraph(
        paragraph,
        Offset(16, (widget.height - paragraph.height) / 2),
      );
    }
    return recorder.endRecording().toImage(
      (390 * pixelRatio).round(),
      (widget.height * pixelRatio).round(),
    );
  }

  void _start(DragStartDetails details) {
    setState(() => _strokes.add([details.localPosition]));
  }

  void _update(DragUpdateDetails details) {
    setState(() => _strokes.last.add(details.localPosition));
    widget.onChanged(hasSignature);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text('Signature', style: Theme.of(context).textTheme.labelMedium),
          const Spacer(),
          TextButton(
            onPressed: hasSignature ? clear : null,
            child: const Text('Clear'),
          ),
        ],
      ),
      Semantics(
        label: 'Signature drawing area',
        child: GestureDetector(
          onPanStart: _start,
          onPanUpdate: _update,
          child: Container(
            height: widget.height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: FishTraceColors.surface,
              border: Border.all(color: FishTraceColors.border),
              borderRadius: BorderRadius.circular(FishTraceRadii.input),
            ),
            clipBehavior: Clip.antiAlias,
            child: CustomPaint(
              painter: _SignaturePainter(_strokes),
              child: hasSignature
                  ? null
                  : Center(
                      child: Text(
                        'Sign here',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
            ),
          ),
        ),
      ),
      const SizedBox(height: FishTraceSpacing.xs),
      TextField(
        controller: _typedSignature,
        autofillHints: const [AutofillHints.name],
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          labelText: 'Typed signature (accessibility alternative)',
          hintText: 'Receiver full name',
        ),
        onChanged: (_) {
          setState(() {});
          widget.onChanged(hasSignature);
        },
      ),
    ],
  );
}

class _SignaturePainter extends CustomPainter {
  const _SignaturePainter(this.strokes);

  final List<List<Offset>> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = FishTraceColors.navy
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (final point in stroke.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
