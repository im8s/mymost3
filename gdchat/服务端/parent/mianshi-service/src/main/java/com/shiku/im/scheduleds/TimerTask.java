package com.shiku.im.scheduleds;

import java.util.concurrent.ScheduledFuture;

/**
 *
 *
 */
public abstract class TimerTask implements Runnable{
	private ScheduledFuture<?> future = null;

	//private  Logger logger = LoggerFactory.getLogger(TimerTask.class.getName());


	public void setScheduledFuture(ScheduledFuture<?> future) {
		this.future = future;
	}

	public boolean isScheduled() {
		return future != null && !future.isCancelled() && !future.isDone();
	}
	
	public void cancel() {
		cancel(false);
	}

	public void cancel(boolean mayInterruptIfRunning) {
		if (future != null && !future.isDone()) {
			future.cancel(mayInterruptIfRunning);
		}
	}
}
