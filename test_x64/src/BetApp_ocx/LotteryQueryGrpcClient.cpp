#include "LotteryQueryGrpcClient.h"

#include "BetCtlManager.h"
#include "ToolFunc.h"


LotteryQueryGrpcClient::LotteryQueryGrpcClient(QObject *parent)
	: QObject(parent)
{
}

LotteryQueryGrpcClient::~LotteryQueryGrpcClient()
{
}

bool LotteryQueryGrpcClient::setParams(const QString& strIp, int port)
{
	QString str = ZN_STR("%1:%2").arg(strIp).arg(port);

	std::shared_ptr<Channel> channel = grpc::CreateChannel(str.toStdString(), grpc::InsecureChannelCredentials());
	stub_ = LotteryQuery::NewStub(channel);

	return true;
}

bool LotteryQueryGrpcClient::fetchLotteryInfo(int tp)
{
	LotteryRequest req;
	req.set_type(tp);

	ClientContext context;
	LotteryResponse res;

	Status status = stub_->FetchLotteryInfo(&context, req, &res);

	if (status.ok())
	{
		BCMGR->processLotteryResMsg(res);

		return true;
	}
	
	return false;
}

