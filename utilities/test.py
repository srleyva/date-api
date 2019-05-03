import requests
import argparse
import logging
import sys

def main(args=sys.argv[1:], **kwargs):
    '''Test the date api '''
    mainparser = argparse.ArgumentParser(
            description='''Test an API''')
    mainparser.add_argument(
        '--host',
        dest='host',
        default='http://localhost:3000',
        help='set verbose logging')
    mainparser.add_argument(
        '-r', '--requests',
        dest='requests',
        default=10,
        help='set number of requests you want on the service'
    )
    parser = mainparser.parse_args(args)

    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s %(levelname)-6s %(message)s')
    logging.info(f'Testing API {parser.host} with {parser.requests} number of requests')

    success = 0
    failure = 0

    for request in range(parser.requests):
        r = requests.get(f'{parser.host}')
        if r.status_code is 200:
            success = success + 1
            status = 'SUCCESS'
        else:
            failure = failure + 1
            status = 'FAILURE'

        logging.info(f'Request {request + 1}: {status} TTLB: {r.elapsed}')
    
    logging.info(f'Success {success}/{parser.requests}')
    logging.info(f'Failure {failure}/{parser.requests}')

if __name__ == "__main__":
    main()

    

