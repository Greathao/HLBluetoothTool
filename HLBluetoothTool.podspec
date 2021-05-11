Pod::Spec.new do |s|
  s.name     = 'HLBluetoothTool' 
  s.version  = '0.0.1' 
#开源协议
  s.license  = "MIT"  
#简单的描述 
  s.summary  = 'This is a bluetooth tool' 
#主页
  s.homepage = 'https://github.com/Greathao/HLBluetoothTool.git' 
#作者
  s.author   = { 'liuhao' => '704550535@qq.com' }  
#作者git路径、指定tag号
  s.source   = { :git => 'https://github.com/Greathao/HLBluetoothTool.git', :tag => "0.0.1" }  
  s.platform = :ios 
  
#库的源代码文件
  s.source_files = "HLBluetoothTool"
  
#依赖的framework 
  s.frameworks = "Foundation","CoreBluetooth"  

  s.requires_arc = true
end
