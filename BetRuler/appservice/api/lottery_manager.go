package api

import (
	"errors"
	"fmt"
	"io/ioutil"
	"net/http"
	"regexp"
	"time"

	"crypto/md5"
	"encoding/hex"
	"sort"
	"strings"

	"BetRuler/pb"
)

var (
	serverTimeUrl = "http://dpc.13070.cn/api/common/serverTime"
	latestLotUrl  = "http://dpc.13070.cn/api/lottery/lastest?loTyp=2"
	historyLotUrl = "http://dpc.13070.cn/api/lottery/lastest?loTyp=2"
	curPeriodsUrl = "http://dpc.13070.cn/api/common/currentPeriods"

	reServerTime = `{"serverTime":"(\w+)"}`
	reLatestLot  = `"lastLottoResults":\{"id":([\w|\W]+?)"lotteryType":\{([\w|\W]+?)\}([\w|\W]+?)\},`
	reHistoryLot = `[,|\[]\{"id":([\w|\W]+?)"lotteryType":\{([\w|\W]+?)\}([\w|\W]+?)\}`
	reCurPeriods = `"result":\{"data":\{([\w|\W]+?)\}`

	secretKey string = "AF241F8CA6E2AC7138F50D713851432F"
)

type LotteryInfo struct {
	Periods     string
	BeginTime   string
	OpenTime    string
	CollectTime string
	OpenContent string
}

type LotteryManager struct {
	Titles []string
}

func NewLotteryManager() (lm *LotteryManager) {
	LMgr := &LotteryManager{
		Titles: []string{
			"lotteryPeriods",
			"lotteryBeginTime",
			"lotteryOpenTime",
			"lotteryCollectTime",
			"lotteryOpenContent",
		},
	}

	return LMgr
}

func (lm *LotteryManager) getUrlContent(url string) (pageStr string, err error) {
	resp, err := http.Get(url)
	if err != nil {
		return
	}

	defer resp.Body.Close()

	allBytes, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return
	}

	pageStr = string(allBytes)

	err = nil
	return
}

func getSign(params map[string]string) string {
	//ksort排序
	var keys []string
	for k := range params {
		keys = append(keys, k)
	}
	sort.Strings(keys)

	//拼接value
	var dataParams string
	for _, v := range keys {
		dataParams += params[v]
	}

	//计算md5
	data := md5.New()
	data.Write([]byte(dataParams + secretKey))
	sign := hex.EncodeToString(data.Sum(nil))

	return sign
}

func (lm *LotteryManager) postUrlContent(url string, headers map[string]string, formData map[string]string) (pageStr string, err error) {
	client := &http.Client{}

	var r http.Request
	r.ParseForm()
	for k, v := range formData {
		r.Form.Add(k, v)
	}
	bodystr := strings.TrimSpace(r.Form.Encode())

	req, err := http.NewRequest("POST", url, strings.NewReader(bodystr))
	if err != nil {
		return "", err
	}
	for key, header := range headers {
		req.Header.Set(key, header)
	}
	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	return string(body), nil
}

func (lm *LotteryManager) getALotteryInfo(periodStr string) (li *LotteryInfo, err error) {
	reg, err := regexp.Compile(`"([a-zA-Z]+?)":(")?([a-zA-Z0-9\+]+?)(")?,`)
	if err != nil {
		//fmt.Println("error occurs: ", err)
		return
	}

	ss := reg.FindAllStringSubmatch(periodStr, -1)
	if ss == nil || len(ss[0]) < 4 {
		err = errors.New("FindAllStringSubmatch: Not match ALotteryInfo")
		return
	}

	kvs := make(map[string]string, len(lm.Titles))

	for _, v := range ss {
		for _, val := range lm.Titles {
			if v[1] == val {
				kvs[val] = v[3]
			}
		}
	}

	// fmt.Println("periodStr = ", periodStr)
	// fmt.Println("")
	// fmt.Println(kvs)
	// fmt.Println("")

	if len(kvs) == len(lm.Titles) {
		li = &LotteryInfo{
			kvs[lm.Titles[0]],
			kvs[lm.Titles[1]],
			kvs[lm.Titles[2]],
			kvs[lm.Titles[3]],
			kvs[lm.Titles[4]],
		}

		//fmt.Println("lotInfo: ", li)

		err = nil
		return
	}

	err = errors.New("GetALotteryInfo error")
	return
}

func (lm *LotteryManager) getACurrentPeriodsLotteryInfo(periodStr string) (li *LotteryInfo, err error) {
	reg, err := regexp.Compile(`"([a-zA-Z]+?)":(")?([a-zA-Z0-9-: ]*?)(")?(,|$)`)
	if err != nil {
		//fmt.Println("error occurs: ", err)
		return
	}

	ss := reg.FindAllStringSubmatch(periodStr, -1)
	if ss == nil || len(ss[0]) < 4 {
		err = errors.New("FindAllStringSubmatch: Not match getACurrentPeriodsLotteryInfo")
		return
	}

	kvs := make(map[string]string, len(lm.Titles))

	for _, val := range lm.Titles {
		b := false
		for _, v := range ss {
			if v[1] == val {
				kvs[val] = v[3]
				b = true
				break
			}
		}
		if !b {
			kvs[val] = ""
		}
	}

	// fmt.Println("periodStr = ", periodStr)
	// fmt.Println("")
	// fmt.Println(kvs)
	// fmt.Println("")

	if len(kvs) == len(lm.Titles) {
		li = &LotteryInfo{
			kvs[lm.Titles[0]],
			kvs[lm.Titles[1]],
			kvs[lm.Titles[2]],
			kvs[lm.Titles[3]],
			kvs[lm.Titles[4]],
		}

		//fmt.Println("lotInfo: ", li)

		err = nil
		return
	}

	err = errors.New("getACurrentPeriodsLotteryInfo error")
	return
}

func (lm *LotteryManager) getServerTime() (st string, err error) {
	pageStr, err := lm.getUrlContent(serverTimeUrl)
	if err != nil {
		return
	}

	// fmt.Println(pageStr)

	reg := regexp.MustCompile(reServerTime)
	if err != nil {
		return
	}

	ss := reg.FindAllStringSubmatch(pageStr, -1)
	if ss == nil || len(ss[0]) < 2 {
		err = errors.New("FindAllStringSubmatch: Not match serverTime")
		return
	}

	// fmt.Println(ss[0][1])

	st = ss[0][1]
	err = nil
	return
}

func (lm *LotteryManager) getLatestLottery() (li *LotteryInfo, err error) {
	pageStr, err := lm.getUrlContent(latestLotUrl)
	if err != nil {
		//fmt.Println("error occurs: ", err)
		return
	}

	// fmt.Println(pageStr)

	reg, err := regexp.Compile(reLatestLot)
	if err != nil {
		//fmt.Println("error occurs: ", err)
		return
	}

	ss := reg.FindAllStringSubmatch(pageStr, -1)
	if ss == nil || len(ss[0]) < 2 {
		err = errors.New("FindAllStringSubmatch: Not match LatestLottery")
		return
	}

	if len(ss) == 1 {
		li, err = lm.getALotteryInfo(ss[0][0])

		return
	}

	err = errors.New("FindAllStringSubmatch: Not match LatestLottery")
	return
}

func (lm *LotteryManager) getHistoryLotteryList() (lotterys []*LotteryInfo, err error) {
	pageStr, err := lm.getUrlContent(historyLotUrl)
	if err != nil {
		//fmt.Println("error occurs: ", err)
		return
	}

	// fmt.Println(pageStr)

	reg, err := regexp.Compile(reHistoryLot)
	if err != nil {
		//fmt.Println("error occurs: ", err)
		return
	}

	ss := reg.FindAllStringSubmatch(pageStr, -1)
	if ss == nil || len(ss[0]) < 2 {
		err = errors.New("FindAllStringSubmatch: Not match HistoryLottery")
		return
	}

	// fmt.Println("len(ss) = ", len(ss), ", len(ss[0]) = ", len(ss[0]), ", len(ss[1]) = ", len(ss[1]))

	for _, v := range ss {
		li, err := lm.getALotteryInfo(v[0])
		if err != nil {
			fmt.Println("error occurs: ", err)
			return lotterys, err
		}

		lotterys = append(lotterys, li)
	}

	err = nil
	return
}

func (lm *LotteryManager) getCurrentPeriods() (li *LotteryInfo, err error) {
	//header
	headers := make(map[string]string)
	headers["Content-Type"] = "application/x-www-form-urlencoded"
	headers["Connection"] = "Keep-Alive"

	//获取时间戳
	tm := time.Now().UTC().Add(8 * time.Hour)
	// fmt.Println(tm)
	date := tm.Format("20060102150405")

	//form data
	formData := map[string]string{
		"lottery_type": "2",
		"timestamp":    date,
	}
	formData["sign"] = getSign(formData)

	// fmt.Println(formData)

	//发起post
	pageStr, err := lm.postUrlContent(curPeriodsUrl, headers, formData)
	if err != nil {
		//fmt.Println("error occurs: ", err)
		return
	}

	// pageStr = `{"code":0,"message":"成功","result":{"data":{"lotteryType":2,"lotteryName":"加拿大28","lotteryPeriods":"2731583","status":1,"lotteryBeginTime":"2021-07-04 18:35:30","lotteryOpenTime":"2021-07-04 18:39:00","lotteryOpenContent":"","lotteryShowContent":"","chartData":null}}}`

	// fmt.Println("GetCurrentPeriods: " + pageStr)

	reg, err := regexp.Compile(reCurPeriods)
	if err != nil {
		//fmt.Println("error occurs: ", err)
		return
	}

	ss := reg.FindAllStringSubmatch(pageStr, -1)
	if ss == nil || len(ss[0]) < 2 {
		fmt.Println("FindAllStringSubmatch: Not match GetCurrentPeriods, pageStr = ", pageStr)
		err = errors.New("FindAllStringSubmatch: Not match GetCurrentPeriods")
		return
	}

	// fmt.Println(ss[0][0])

	// fmt.Println(ss[0][1])

	if len(ss) == 1 {
		li, err = lm.getACurrentPeriodsLotteryInfo(ss[0][1])

		return
	}

	err = errors.New("FindAllStringSubmatch: Not match GetCurrentPeriods")
	return
}

func (lm *LotteryManager) doLotteryStateForLotteryResMsg(tp int32, code int32) (res *pb.LotteryResponse, err error) {
	msg := &pb.LotteryResponse{
		Data: &pb.LotteryResponse_LotStatus{
			LotStatus: &pb.LotteryState{
				Type: tp,
				Code: code,
			},
		},
	}

	return msg, nil
}

func (lm *LotteryManager) doServerTimeForLotteryResMsg(tp int32) (res *pb.LotteryResponse, err error) {
	dtstr, err := lm.getServerTime()
	if err != nil {
		fmt.Println("doServerTimeForLotteryResMsg error: ", err)
		res, err = lm.doLotteryStateForLotteryResMsg(tp, -1)
		return
	}

	msg := &pb.LotteryResponse{
		Data: &pb.LotteryResponse_LotServer{
			LotServer: &pb.LotteryServer{
				ServerTime: dtstr,
			},
		},
	}

	return msg, nil
}

func (lm *LotteryManager) doHistoryListForLotteryResMsg(tp int32) (res *pb.LotteryResponse, err error) {
	lotterys, err := lm.getHistoryLotteryList()
	if err != nil {
		fmt.Println("doHistoryListForLotteryResMsg error: ", err)
		res, err = lm.doLotteryStateForLotteryResMsg(tp, -1)
		return
	}

	lotList := &pb.LotteryList{}

	for _, lot := range lotterys {
		li := &pb.LotteryInfo{
			Periods:     lot.Periods,
			BeginTime:   lot.BeginTime,
			OpenTime:    lot.OpenTime,
			CollectTime: lot.CollectTime,
			OpenContent: lot.OpenContent,
		}

		lotList.Lotterys = append(lotList.Lotterys, li)
	}

	// fmt.Println("doHistoryListForLotteryResMsg::lotterys: size = ", len(lotList.Lotterys))

	msg := &pb.LotteryResponse{
		Data: &pb.LotteryResponse_LotList{
			LotList: lotList,
		},
	}

	return msg, nil
}

func (lm *LotteryManager) doNextPeriodsForLotteryResMsg(tp int32) (res *pb.LotteryResponse, err error) {
	li, err := lm.getCurrentPeriods()
	if err != nil {
		fmt.Println("doNextPeriodsForLotteryResMsg error: ", err)
		res, err = lm.doLotteryStateForLotteryResMsg(tp, -1)
		return
	}

	fmt.Println("doNextPeriodsForLotteryResMsg: Periods = " + li.Periods + ", OpenContent = " + li.OpenContent)

	msg := &pb.LotteryResponse{
		Data: &pb.LotteryResponse_LotNext{
			LotNext: &pb.LotteryNext{
				LotInfo: &pb.LotteryInfo{
					Periods:     li.Periods,
					BeginTime:   li.BeginTime,
					OpenTime:    li.OpenTime,
					CollectTime: li.CollectTime,
					OpenContent: li.OpenContent,
				},
			},
		},
	}

	return msg, nil
}

func (lm *LotteryManager) doLatestPeriodsForLotteryResMsg(tp int32) (res *pb.LotteryResponse, err error) {
	li, err := lm.getLatestLottery()
	if err != nil {
		fmt.Println("doLatestPeriodsForLotteryResMsg error: ", err)
		res, err = lm.doLotteryStateForLotteryResMsg(tp, -1)
		return
	}

	fmt.Println("doLatestPeriodsForLotteryResMsg: Periods = " + li.Periods + ", OpenContent = " + li.OpenContent)

	msg := &pb.LotteryResponse{
		Data: &pb.LotteryResponse_LotLatest{
			LotLatest: &pb.LotteryLatest{
				LotInfo: &pb.LotteryInfo{
					Periods:     li.Periods,
					BeginTime:   li.BeginTime,
					OpenTime:    li.OpenTime,
					CollectTime: li.CollectTime,
					OpenContent: li.OpenContent,
				},
			},
		},
	}

	return msg, nil
}

func (lm *LotteryManager) FetchLotteryInfo(req *pb.LotteryRequest) (res *pb.LotteryResponse, err error) {
	tp := req.Type

	fmt.Println("req.Type: tp = ", tp)

	if 0 == tp || 10 == tp {
		return lm.doServerTimeForLotteryResMsg(tp)
	} else if 1 == tp || 11 == tp {
		return lm.doHistoryListForLotteryResMsg(tp)
	} else if 2 == tp || 12 == tp {
		return lm.doNextPeriodsForLotteryResMsg(tp)
	} else if 3 == tp || 13 == tp {
		return lm.doLatestPeriodsForLotteryResMsg(tp)
	}

	// return nil, errors.New("unknown request")
	return lm.doLotteryStateForLotteryResMsg(tp, -1)
}
