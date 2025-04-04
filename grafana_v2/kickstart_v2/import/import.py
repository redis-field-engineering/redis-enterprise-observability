import argparse
import datetime
import redis

arg_parser = argparse.ArgumentParser(description='demo loader')
arg_parser.add_argument('-r', '--redis', default="localhost", help="Redis URL to connect to.")
arg_parser.add_argument('-p', '--port', default=12000, type=int, help="Redis URL to connect to.")
arg_parser.add_argument('-d', '--database', default=0, type=int, help="Redis database to connect to.")
arg_parser.add_argument('-u', '--user', default='default', type=str, help="Redis user.")
arg_parser.add_argument('-w', '--word', default='dashboard', type=str, help="Redis password.")


if __name__ == '__main__':
    args = arg_parser.parse_args()

    creds_provider = redis.UsernamePasswordCredentialProvider(args.user, args.word)
    r = redis.Redis(host=args.redis, port=args.port, credential_provider=creds_provider)

    try:
        for x in range(0, 1000):
            data = {"time": datetime.datetime.now().timestamp(), "name": f'demo:{x}', "age": x}
            r.hset(f'demo:{x}', mapping=data)
    except Exception as ex:
        print(str(ex))
