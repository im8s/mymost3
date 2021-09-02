package api

import (
	"BetRuler/pb"
	"context"
)

type LotteryQueryService struct {
	lmgr *LotteryManager
}

func NewLotteryQueryService() (lqs *LotteryQueryService) {
	lqs = &LotteryQueryService{
		lmgr: NewLotteryManager(),
	}

	return
}

func (lqs *LotteryQueryService) FetchLotteryInfo(ctx context.Context, req *pb.LotteryRequest) (res *pb.LotteryResponse, err error) {
	res, err = lqs.lmgr.FetchLotteryInfo(req)
	return
}
