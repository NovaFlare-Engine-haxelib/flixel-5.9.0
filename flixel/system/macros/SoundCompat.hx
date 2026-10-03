package flixel.system.macros;
#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
class SoundCompat {
 public static function build():Array<Field> {
  var fields=Context.getBuildFields(); var cls=Context.getLocalClass().get();
  if(cls.pack.join(".")+"."+cls.name=="funkin.audio.FunkinSound")
   fields=fields.filter(f->f.name!="paused" && f.name!="get_paused");
  return fields;
 }
}
#end
