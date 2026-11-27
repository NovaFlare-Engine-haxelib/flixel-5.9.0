package flixel.graphics.tile;

import flixel.FlxCamera;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawBaseItem.FlxDrawItemType;
import flixel.system.FlxAssets.FlxShader;
import flixel.math.FlxMatrix;
import openfl.geom.ColorTransform;
import openfl.display.ShaderParameter;
import openfl.Vector;

class FlxDrawQuadsItem extends FlxDrawBaseItem<FlxDrawQuadsItem>
{
	static inline var VERTICES_PER_QUAD = #if (openfl >= "8.5.0") 4 #else 6 #end;

	

	var rects:Vector<Float>;
	var transforms:Vector<Float>;
	var alphas:Array<Float>;
	var colorMultipliers:Array<Float>;
	var colorOffsets:Array<Float>;
	#if (novaflare_compact_quad_shader_attributes && cpp && !nme && openfl >= "8.5.0")
	var colorCopies:Int = 0;
	#end

	public function new()
	{
		super();
		type = FlxDrawItemType.TILES;
		rects = new Vector<Float>();
		transforms = new Vector<Float>();
		alphas = [];
	}

	override public function reset():Void
	{
		super.reset();
		#if (novaflare_compact_quad_shader_attributes && cpp && !nme && openfl >= "8.5.0")
		colorCopies = 0;
		#end
		rects.length = 0;
		transforms.length = 0;
		alphas.splice(0, alphas.length);
		if (colorMultipliers != null)
			colorMultipliers.splice(0, colorMultipliers.length);
		if (colorOffsets != null)
			colorOffsets.splice(0, colorOffsets.length);
	}

	override public function dispose():Void
	{
		super.dispose();
		rects = null;
		transforms = null;
		alphas = null;
		colorMultipliers = null;
		colorOffsets = null;
	}

	override public function addQuad(frame:FlxFrame, matrix:FlxMatrix, ?transform:ColorTransform):Void
	{
		var rect = frame.frame;
		var scaleX = frame.parent.textureScaleX;
		var scaleY = frame.parent.textureScaleY;
		rects.push(rect.x * scaleX);
		rects.push(rect.y * scaleY);
		rects.push(rect.width * scaleX);
		rects.push(rect.height * scaleY);

		// The backend transforms vertices built from stored bitmap pixels.
		var logicalScaleX = 1 / scaleX;
		var logicalScaleY = 1 / scaleY;
		transforms.push(matrix.a * logicalScaleX);
		transforms.push(matrix.b * logicalScaleX);
		transforms.push(matrix.c * logicalScaleY);
		transforms.push(matrix.d * logicalScaleY);
		transforms.push(matrix.tx);
		transforms.push(matrix.ty);

		#if (novaflare_compact_quad_shader_attributes && cpp && !nme && openfl >= "8.5.0")
		if (colorCopies == 0)
			colorCopies = shader == null && graphics != null && Type.getClass(graphics.shader) == FlxGraphicsShader ? 1 : VERTICES_PER_QUAD;
		final copies = colorCopies;
		#else
		final copies = VERTICES_PER_QUAD;
		#end
		var alphaMultiplier = transform != null ? transform.alphaMultiplier : 1.0;
		for (i in 0...copies)
			alphas.push(alphaMultiplier);

		if (colored || hasColorOffsets)
		{
			if (colorMultipliers == null)
				colorMultipliers = [];

			if (colorOffsets == null)
				colorOffsets = [];

			for (i in 0...copies)
			{
				if (transform != null)
				{
					colorMultipliers.push(transform.redMultiplier);
					colorMultipliers.push(transform.greenMultiplier);
					colorMultipliers.push(transform.blueMultiplier);

					colorOffsets.push(transform.redOffset);
					colorOffsets.push(transform.greenOffset);
					colorOffsets.push(transform.blueOffset);
					colorOffsets.push(transform.alphaOffset);
				}
				else
				{
					colorMultipliers.push(1);
					colorMultipliers.push(1);
					colorMultipliers.push(1);

					colorOffsets.push(0);
					colorOffsets.push(0);
					colorOffsets.push(0);
					colorOffsets.push(0);
				}

				colorMultipliers.push(1);
			}
		}
	}

	#if !flash
	override public function render(camera:FlxCamera):Void
	{
		if (rects.length == 0)
			return;
		
		// TODO: catch this error when the dev actually messes up, not in the draw phase
		if (shader == null && graphics.isDestroyed)
			throw 'Attempted to render an invalid FlxDrawItem, did you destroy a cached sprite?';
		
		final shader = shader != null ? shader : graphics.shader;
		shader.bitmap.input = graphics.bitmap;
		shader.bitmap.filter = (#if CODENAME_ENGINE_COMPAT FlxG.enableAntialiasing && #end (camera.antialiasing || antialiasing)) ? LINEAR : NEAREST;
		final hasColors = colored || hasColorOffsets;
		setParameterValue(shader.hasTransform, true);
		setParameterValue(shader.hasColorTransform, hasColors);

		#if (openfl > "8.7.0")
		camera.canvas.graphics.overrideBlendMode(blend);
		#end
		final canvasGraphics = camera.canvas.graphics;
		final compactFill = #if (novaflare_compact_quad_shader_attributes && cpp && !nme && openfl >= "8.5.0")
			colorCopies == 1 && this.shader == null && Type.getClass(shader) == FlxGraphicsShader
				&& canvasGraphics.__beginCompactQuadShaderFill(shader, alphas, hasColors ? colorMultipliers : null, hasColors ? colorOffsets : null);
		#else
			false;
		#end
		if (!compactFill)
		{
			#if (novaflare_compact_quad_shader_attributes && cpp && !nme && openfl >= "8.5.0")
			useVertexColors();
			#end
			shader.alpha.value = alphas;
			if (hasColors)
			{
				shader.colorMultiplier.value = colorMultipliers;
				shader.colorOffset.value = colorOffsets;
			}
			canvasGraphics.beginShaderFill(shader);
		}
		canvasGraphics.drawQuads(rects, null, transforms);
		super.render(camera);
	}

	inline function setParameterValue(parameter:ShaderParameter<Bool>, value:Bool):Void
	{
		if (parameter.value == null)
			parameter.value = [];
		parameter.value[0] = value;
	}
	#end

	#if (novaflare_compact_quad_shader_attributes && cpp && !nme && openfl >= "8.5.0")
	private function useVertexColors():Void
	{
		if (colorCopies == 1)
		{
			expandQuadAttribute(alphas, 1);
			if (colorMultipliers != null) expandQuadAttribute(colorMultipliers, 4);
			if (colorOffsets != null) expandQuadAttribute(colorOffsets, 4);
		}
		colorCopies = VERTICES_PER_QUAD;
	}

	private static function expandQuadAttribute(values:Array<Float>, components:Int):Void
	{
		final quadCount = Std.int(values.length / components);
		values.resize(values.length * VERTICES_PER_QUAD);
		// Expand backwards so earlier compact values are still available.
		for (offset in 0...quadCount)
		{
			final quad = quadCount - 1 - offset;
			final source = quad * components;
			final destination = source * VERTICES_PER_QUAD;
			for (vertex in 0...VERTICES_PER_QUAD)
			{
				for (component in 0...components)
					values[destination + vertex * components + component] = values[source + component];
			}
		}
	}
	#end

public function addColoredQuad(frame:FlxFrame,matrix:FlxMatrix,?transforms:Array<ColorTransform>):Void {
  #if (novaflare_compact_quad_shader_attributes && cpp && !nme && openfl >= "8.5.0")
  if (transforms != null && transforms.length > 0) useVertexColors();
  #end
  var start=alphas.length; addQuad(frame,matrix,transforms!=null&&transforms.length>0?transforms[0]:null);
  if(transforms==null || transforms.length==0) return;
  for(i in 0...VERTICES_PER_QUAD) {
   var c=transforms[i%transforms.length]; if(c==null) c=FlxDrawBaseItem.colorIdentity; alphas[start+i]=c.alphaMultiplier;
   if(colored||hasColorOffsets) {var k=(start+i)*4;
    colorMultipliers[k]=c.redMultiplier; colorMultipliers[k+1]=c.greenMultiplier; colorMultipliers[k+2]=c.blueMultiplier; colorMultipliers[k+3]=1;
    colorOffsets[k]=c.redOffset; colorOffsets[k+1]=c.greenOffset; colorOffsets[k+2]=c.blueOffset; colorOffsets[k+3]=c.alphaOffset;
   }
  }
 }
}
