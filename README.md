# Makefileファイルで動かすSTM32F4-Discovery

STM32Cubeで作成したプロジェクトをMakefileでコマンドラインからmakeできるようにする。

## プロジェクト: STM32_USB_Host_LibraryとFatFsを使ってUSBメモリを操作する

`Controllerstech: Robotics Simpliefied`サイトの記事[STM32 USB HOST MSC](https://controllerstech.com/stm32-usb-host-msc/)をそのまま使用した。ビデオも非常に参考になった。

## STM32_USB_Host_LibraryとFatFsを使うための処理の内容

STM32Cubeが作成したソースに上記サイトからダウンロードした３つのファイル`File_Handling.[ch]`と`usb_host.c`を追加または上書きした。変更があったファイルは`USB_HOST/App/usb_host.c`だけであり、
この中の`USBH_UserProcess()`関数に行いたい処理が追加されていた。個々の処理は関数化され、
`Core/Src/File_Handling.c`にまとめられていた。

## 実行結果

```
USB mounted successfully...
USB  Total Size:        3908100
USB Free Space:         546628
File: //dspace-1.4.2-source.tar.gz
Dir: dspace-1.4.2-source

Dir: bin

*/rootfile.txt* created successfully
 Now use Write_File to write data
File */rootfile.txt* CLOSED successfully

Opening file-->  */rootfile.txt*  To WRITE data in it
File */rootfile.txt* is WRITTEN and CLOSED successfully

*/dir1* has been created successfully

*dir1/dir1file.txt* created successfully
 Now use Write_File to write data
File *dir1/dir1file.txt* CLOSED successfully

Opening file-->  */dir1/dir1file.txt*  To WRITE data in it
File */dir1/dir1file.txt* is WRITTEN and CLOSED successfully

*/dir2* has been created successfully

*/dir2/subdir1* has been created successfully

*/dir2/subdir1/dir2file.txt* created successfully
 Now use Write_File to write data
File */dir2/subdir1/dir2file.txt* CLOSED successfully

Opening file-->  */dir2/subdir1/dir2file.txt*  To WRITE data in it
File */dir2/subdir1/dir2file.txt* is WRITTEN and CLOSED successfully

Opening file-->  */rootfile.txt*  To UPDATE data in it
*/rootfile.txt* UPDATED successfully
File */rootfile.txt* CLOSED successfully
                                                 # <= ここでUSBメモリを抜く
USB UNMOUNTED successfully...
```
