#pragma once

#include "gdata.h"
//#include "pdata.h"

#include <QObject>

#include <grpcpp/grpcpp.h>

#include "br.grpc.pb.h"

using grpc::Channel;
using grpc::ClientContext;
using grpc::Status;

using pb::LotteryQuery;
using pb::LotteryRequest;
using pb::LotteryResponse;


class LotteryQueryGrpcClient : public QObject
{
	Q_OBJECT

public:
	LotteryQueryGrpcClient(QObject *parent = nullptr);
	~LotteryQueryGrpcClient();

	bool setParams(const QString& strIp, int port);

	bool fetchLotteryInfo(int tp);

Q_SIGNALS:
	void setLotteryState(int type, int code);
	void setLotteryServerTime(const tServerTime& st);
	void setLotteryHistory(const tLotteryRefMap& coll);
	void setLotteryNext(const tLottery& lot);
	void setLotteryLatest(const tLottery& lot);

public Q_SLOTS:

private:
	void processLotteryResMsg(const LotteryResponse& msg);

private:
	std::unique_ptr<LotteryQuery::Stub>		stub_;
};
