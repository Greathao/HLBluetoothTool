Pod::Spec.new do |s|
  s.name     = 'HLBluetoothTool' 
  s.version  = '0.0.1' 
  s.license  = "MIT"  //开源协议
  s.summary  = 'This is a bluetooth tool' //简单的描述 
  s.homepage = 'https://github.com/Greathao/HLBluetoothTool' //主页
  s.author   = { 'liuhao' => '704550535@qq.com' } //作者
  s.source   = { :git => 'https://github.com/Greathao/HLBluetoothTool.git', :tag => "0.0.1" } //git路径、指定tag号
  s.platform = :ios 
  s.source_files = 'HLBluetoothTool/*'  //库的源代码文件
  s.frameworks = "Foundation","CoreBluetooth"  //依赖的framework
  s.requires_arc = true
end
