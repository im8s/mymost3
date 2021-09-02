#!/bin/bash
protoc --go_out=. br.proto
protoc --cpp_out=. br.proto

protoc --go_out=plugins=grpc:. br.proto

protoc -I="./" --grpc_out="./" --plugin=protoc-gen-grpc="D:\Program Files\grpc\x64\debug\bin\grpc_cpp_plugin.exe" "br.proto"

protoc -I="." --cpp_out="." "br.proto"

protoc --cpp_out=plugins=grpc:. br.proto

protoc --cpp_out=grpc_cpp_plugin:. br.proto