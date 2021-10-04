#include <iostream>
#include <fstream>
#include <cmath>
#include <cstdlib>
#include <ctime>
using namespace std;

int main()
{
	srand( time(NULL) );

	int cache_size, block_size, associativity, replace_algo, cache_block, way, set_num, hit;
	unsigned int addr=0, block_addr, cache_index, cache_tag, now_index, temp_tag, index_rand;

	ifstream inFile("trace1.txt", ios::in);
	ofstream outFile("trace1.out", ios::out);

	inFile >> cache_size >> block_size >> associativity >> replace_algo;
	cache_block = cache_size*1024 / block_size;
	if(associativity == 0)
		way=1;
	else if(associativity == 1)
		way=4;
	else if(associativity == 2)
		way=cache_block;
		
	set_num=cache_block/way;
	int cache[way][set_num];
	for(int i=0; i<way; ++i)
		for(int j=0; j<set_num; ++j)
			cache[i][j]=-1;

	while(inFile >> hex >> addr)
	{
		block_addr = addr/block_size;
		cache_index = block_addr % set_num;
		cache_tag = block_addr / set_num;

		if(associativity == 0)
		{
			if(cache[0][cache_index] != -1)
			{
				if(cache[0][cache_index] == cache_tag)
					outFile << "-1" << endl;
				else
				{
					outFile << cache[0][cache_index] << endl;
					cache[0][cache_index] =cache_tag;
				}
			}
			else
			{
				outFile << "-1" << endl;
				cache[0][cache_index] = cache_tag;
			}
		}
		else if(associativity == 1)
		{
			if(replace_algo == 0)
			{
				hit=0;
				for(int i=0; i<way; ++i)
				{
					if(cache[i][cache_index] == cache_tag)
					{
						outFile << "-1" << endl;
						hit=1;
						break;
					}
				}
				if(hit==1)
					continue;

				if(cache[3][cache_index] != -1)
				{
					outFile << cache[0][cache_index] << endl;
					for(int i=0; i<way-1; ++i)
						cache[i][cache_index] = cache[i+1][cache_index];
					cache[3][cache_index] = cache_tag;
				}
				else
				{
					outFile << "-1" << endl;
					for(int i=0; i<way; ++i)
						if(cache[i][cache_index] == -1)
						{
							cache[i][cache_index]=cache_tag;
							break;
						}
				}
			}
			else if(replace_algo == 1)
			{
				hit=0;
				for(int i=0; i<way; ++i)
				{
					if(cache[i][cache_index] == cache_tag)
					{
						outFile << "-1" << endl;
						now_index=i;
						hit=1;
					}
					else if(cache[i][cache_index] == -1 || i==way-1)
					{
						int temp_tag=cache[now_index][cache_index];
						for(int j=now_index; j<i; ++j)
							cache[j][cache_index]=cache[j+1][cache_index];
						cache[i-1][cache_index] = temp_tag;
					}
				}
				if(hit==1)
					continue;

				if(cache[3][cache_index] != -1)
				{
					outFile << cache[0][cache_index] << endl;
					for(int i=0; i<way-1; ++i)
						cache[i][cache_index] = cache[i+1][cache_index];
					cache[3][cache_index] = cache_tag;
				}
				else
				{
					outFile << "-1" << endl;
					for(int i=0; i<way; ++i)
						if(cache[i][cache_index] == -1)
							cache[i][cache_index]=cache_tag;
				}
			}
			else if(replace_algo == 2)
			{
				hit=0;
				for(int i=0; i<way; ++i)
				{
					if(cache[i][cache_index] == cache_tag)
					{
						outFile << "-1" << endl;
						hit=1;
						break;
					}
				}
				if(hit==1)
					continue;

				if(cache[3][cache_index] != -1)
				{
					index_rand = rand() % (way-1 - 0 + 1) + 0;
					outFile << cache[index_rand][cache_index] << endl;
					cache[index_rand][cache_index] = cache_tag;
				}
				else
				{
					outFile << "-1" << endl;
					for(int i=0; i<way; ++i)
						if(cache[i][cache_index] == -1)
						{
							cache[i][cache_index]=cache_tag;
							break;
						}
				}
			}
		}
		else if(associativity == 2)
		{
			if(replace_algo == 0)
			{
				int hit=0;
				for(int i=0; i<way; ++i)
				{
					if(cache[i][cache_index] == cache_tag)
					{
						outFile << "-1" << endl;
						hit=1;
					}
				}
				if(hit==1)
					continue;

				if(cache[way-1][cache_index] != -1)
				{
					outFile << cache[0][cache_index] << endl;
					for(int i=0; i<way-1; ++i)
						cache[i][cache_index] = cache[i+1][cache_index];
					cache[way-1][cache_index] = cache_tag;
				}
				else
				{
					outFile << "-1" << endl;
					for(int i=0; i<way; ++i)
						if(cache[i][cache_index] == -1)
							cache[i][cache_index]=cache_tag;
				}
			}
			else if(replace_algo == 1)
			{
				hit=0;
				for(int i=0; i<way; ++i)
				{
					if(cache[i][cache_index] == cache_tag)
					{
						outFile << "-1" << endl;
						now_index=i;
						hit=1;
					}
					else if(hit==1 && (cache[i][cache_index] == -1 || i==way-1) )
					{
						temp_tag=cache[now_index][cache_index];
						for(int j=now_index; j<i; ++j)
							cache[j][cache_index]=cache[j+1][cache_index];
						cache[i-1][cache_index] = temp_tag;
						break;
					}
				}
				if(hit==1)
					continue;

				if(cache[way-1][cache_index] != -1)
				{
					outFile << cache[0][cache_index] << endl;
					for(int i=0; i<way-1; ++i)
						cache[i][cache_index] = cache[i+1][cache_index];
					cache[way-1][cache_index] = cache_tag;
				}
				else
				{
					outFile << "-1" << endl;
					for(int i=0; i<way; ++i)
						if(cache[i][cache_index] == -1)
                        {
							cache[i][cache_index]=cache_tag;
							break;
                        }
				}
			}
			else if(replace_algo == 2)
			{
				hit=0;
				for(int i=0; i<way; ++i)
				{
					if(cache[i][cache_index] == cache_tag)
					{
						outFile << "-1" << endl;
						hit=1;
						break;
					}
				}
				if(hit==1)
					continue;

				if(cache[way-1][cache_index] != -1)
				{
					index_rand = rand() % (way-1 - 0 + 1) + 0;
					outFile << cache[index_rand][cache_index] << endl;
					cache[index_rand][cache_index] = cache_tag;
				}
				else
				{
					outFile << "-1" << endl;
					for(int i=0; i<way; ++i)
						if(cache[i][cache_index] == -1)
						{
							cache[i][cache_index]=cache_tag;
							break;
						}
				}
			}
		}
	}
}

