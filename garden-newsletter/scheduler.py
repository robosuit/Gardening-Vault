import schedule
import time
from run_newsletter import run


def start_scheduler():
    # schedule the job for 6:00 AM every day
    schedule.every().day.at("06:00").do(run)

    print("Scheduler started, press Ctrl-C to stop")
    try:
        while True:
            schedule.run_pending()
            time.sleep(30)
    except KeyboardInterrupt:
        print("Scheduler stopped by user")


if __name__ == "__main__":
    start_scheduler()
