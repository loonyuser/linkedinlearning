gcloud --project=loony-learn \
pubsub topics publish stockdata \
--message="{'index': 'S&P 500', 'open': '4250.75','ltp': '4300.01'}" \
--attribute=time='2022-02-01T11:00:00Z'

gcloud --project=loony-learn \
pubsub topics publish stockdata \
--message="{'index': 'S&P 500', 'open': '4250.75','ltp': '4310.79'}" \
--attribute=time='2022-02-01T11:01:00Z'

gcloud --project=loony-learn \
pubsub topics publish stockdata \
--message="{'index': 'NIFTY', 'open': '16920.27','ltp': '17023.00'}" \
--attribute=time='2022-02-01T11:01:00Z'

gcloud --project=loony-learn \
pubsub topics publish stockdata \
--message="{'index': 'S&P 500', 'open': '4250.75','ltp': '4317.01'}" \
--attribute=time='2022-02-01T11:01:30Z'

gcloud --project=loony-learn \
pubsub topics publish stockdata \
--message="{'index': 'S&P 500', 'open': '4250.75','ltp': '4322.79'}" \
--attribute=time='2022-02-01T11:02:00Z'

gcloud --project=loony-learn \
pubsub topics publish stockdata \
--message="{'index': 'NIFTY', 'open': '16920.27','ltp': '17024.00'}" \
--attribute=time='2022-02-01T11:02:00Z'