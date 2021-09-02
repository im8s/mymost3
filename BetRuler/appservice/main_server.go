package main

import (
	"fmt"
	"net"

	"google.golang.org/grpc"

	"BetRuler/appservice/api"
	"BetRuler/appservice/utils"
	"BetRuler/pb"

	"os"

	"github.com/kardianos/service"
)

type program struct{}

func (p *program) Start(s service.Service) error {
	// Start should not block. Do the actual work async.

	go p.run()

	return nil
}

func (p *program) run() {
	server := grpc.NewServer()

	pb.RegisterLotteryQueryServer(server, api.NewLotteryQueryService())

	addr := fmt.Sprintf("%s:%d", utils.GlobalObject.Host, utils.GlobalObject.TCPPort)

	listen, err := net.Listen("tcp", addr)
	if err != nil {
		panic(err.Error())
	}

	fmt.Println("Server listen at ", addr)

	server.Serve(listen)
}

func (p *program) Stop(s service.Service) error {
	// Stop should not block. Return with a few seconds.

	return nil
}

func main() {
	svcConfig := &service.Config{
		Name: "BetRuler",

		DisplayName: "BetRuler",

		Description: "This is an BetRuler service.",
	}

	prg := &program{}

	s, err := service.New(prg, svcConfig)

	if err != nil {
		fmt.Println("创建服务失败，", err)

		return
	}

	if len(os.Args) > 1 {
		if os.Args[1] == "install" {
			err := s.Install()

			if err != nil {
				fmt.Println("服务安装失败，", err)

			} else {
				fmt.Println("服务安装成功")

			}

			return
		}

		if os.Args[1] == "uninstall" {
			err := s.Uninstall()

			if err != nil {
				fmt.Println("服务卸载失败，", err)

			} else {
				fmt.Println("服务卸载成功")

			}

			return
		}

		if os.Args[1] == "start" {
			err := s.Start()

			if err != nil {
				fmt.Println("启动服务失败，", err)

			} else {
				fmt.Println("启动服务成功")
			}

			return
		}

		if os.Args[1] == "stop" {
			err := s.Stop()

			if err != nil {
				fmt.Println("停止服务失败，", err)

			} else {
				fmt.Println("停止服务成功")

			}

			return
		}
	}

	fmt.Println("服务正在启动...")

	err = s.Run()

	if err != nil {
		fmt.Println("服务运行失败，", err)

		return
	}

	fmt.Println("服务正常停止")
}
