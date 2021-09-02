package main

import (
	"BetRuler/pb"
	"context"
	"fmt"

	"google.golang.org/grpc"
)

func main() {

	conn, err := grpc.Dial("localhost:8090", grpc.WithInsecure())
	if err != nil {
		panic(err.Error())
	}
	defer conn.Close()

	client := pb.NewLotteryQueryClient(conn)

	var tp int32 = -1

	for {
		tp++
		if tp > 4 {
			tp = 0
		}

		req := &pb.LotteryRequest{Type: tp}
		res, err := client.FetchLotteryInfo(context.Background(), req)
		if err != nil {
			fmt.Println("client.FetchLotteryInfo error: ", err)
		}

		lotStatus := res.GetLotStatus()
		if lotStatus != nil {
			fmt.Println("LotStatus: Type = ", lotStatus.Type, ", Code = ", lotStatus.Code)
		}

		lotServer := res.GetLotServer()
		if lotServer != nil {
			fmt.Println("lotServer: ServerTime = ", lotServer.ServerTime)
		}

		lotList := res.GetLotList()
		if lotList != nil {
			for _, lot := range lotList.Lotterys {
				fmt.Println("lot.Periods = ", lot.Periods, ", lot.BeginTime = ", lot.BeginTime,
					", lot.OpenTime = ", lot.OpenTime, ", lot.OpenContent = ", lot.OpenContent)
			}
		}

		lotNext := res.GetLotNext()
		if lotNext != nil {
			lot := lotNext.LotInfo
			fmt.Println("lotNext: lot.Periods = ", lot.Periods, ", lot.BeginTime = ", lot.BeginTime,
				", lot.OpenTime = ", lot.OpenTime, ", lot.OpenContent = ", lot.OpenContent)
		}

		lotLatest := res.GetLotLatest()
		if lotLatest != nil {
			lot := lotLatest.LotInfo
			fmt.Println("lotLatest: lot.Periods = ", lot.Periods, ", lot.BeginTime = ", lot.BeginTime,
				", lot.OpenTime = ", lot.OpenTime, ", lot.OpenContent = ", lot.OpenContent)
		}
	}

}
