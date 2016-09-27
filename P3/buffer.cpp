/**
 * @author See Contributors.txt for code contributors and overview of BadgerDB.
 *
 * @section LICENSE
 * Copyright (c) 2012 Database Group, Computer Sciences Department, University of Wisconsin-Madison.
 */

#include <memory>
#include <iostream>
#include "buffer.h"
#include "exceptions/buffer_exceeded_exception.h"
#include "exceptions/page_not_pinned_exception.h"
#include "exceptions/page_pinned_exception.h"
#include "exceptions/bad_buffer_exception.h"
#include "exceptions/hash_not_found_exception.h"

namespace badgerdb { 

	BufMgr::BufMgr(std::uint32_t bufs)
		: numBufs(bufs) {
			bufDescTable = new BufDesc[bufs];

			for (FrameId i = 0; i < bufs; i++) 
			{
				bufDescTable[i].frameNo = i;
				bufDescTable[i].valid = false;
			}

			bufPool = new Page[bufs];

			int htsize = ((((int) (bufs * 1.2))*2)/2)+1;

			hashTable = new BufHashTbl (htsize);  // allocate the buffer hash table

			clockHand = bufs - 1;
		}


	BufMgr::~BufMgr() {
		for (std::uint32_t i = 0; i < numBufs; i++) 
		{
			BufDesc* tmpbuff = &bufDescTable[i];
			if (tmpbuff->valid == true && tmpbuff->dirty == true)
			{
				tmpbuff->file->writePage(bufPool[i]);
			}
		}

		delete [] bufDescTable;
		delete [] bufPool;
		delete hashTable;
	}

	void BufMgr::advanceClock()
	{	
		//advance the clock hand in a modular style
		clockHand = (clockHand+1)%numBufs;
	}

	void BufMgr::allocBuf(FrameId & frame) 
	{
		clockHand = frame;
		for(unsigned int i = 0; i < numBufs*2; i++){//go two rounds so we can make sure that all buffers are pinned
			BufDesc* curr = &bufDescTable[clockHand];
			//check validity of the buffer
			if(curr->valid == false) {
				frame = clockHand;
				return;
			}
			//update refbit
			if(curr->refbit == true) {
				curr->refbit = false;
				advanceClock();
				continue;
			}
			else{
				//check pin count
				if(curr->pinCnt != 0){
					advanceClock();
					continue;
				}
				else{  	//if dirty, write back
					if(curr->dirty == true){				
						curr->file->writePage(bufPool[clockHand]);
					}
					//clear hashtable,bufdesc table, and the frameId
					hashTable->remove(curr->file, curr->pageNo);
					curr->Clear();
					frame = clockHand;
					return;
				}
			}
		}
		//outside the loop means no buffer is available
		throw BufferExceededException();
	}



	void BufMgr::readPage(File* file, const PageId pageNo, Page*& page)
	{
		FrameId id = 0;
		try{
			//check if page already in buffer
			hashTable->lookup(file, pageNo, id);
		}
		catch(HashNotFoundException e) {
			//if not in buffer, read from file and put it in buffer
			allocBuf(clockHand);
			bufPool[clockHand]= file->readPage(pageNo);
			//set up return value
			page = &bufPool[clockHand];
			//set up other tables
			hashTable->insert(file, page->page_number(), clockHand);
			bufDescTable[clockHand].Set(file, page->page_number());
			return;

		}
		//update reference and return
		bufDescTable[id].refbit = true;
		bufDescTable[id].pinCnt ++;
		page = &bufPool[id];
		return;

	}


	void BufMgr::unPinPage(File* file, const PageId pageNo, const bool dirty) 
	{
		// the frame number of the page
		FrameId frameNo = numBufs;
		hashTable->lookup(file, pageNo, frameNo);
		// do nothing if page is not found in hashtable;
		if(frameNo == numBufs){
			return;
		}
		// throw exception if unpinned
		if(bufDescTable[frameNo].pinCnt == 0){
			throw PageNotPinnedException(file->filename(),pageNo, frameNo);
		}
		// set pin count and dirty bit
		else{
			bufDescTable[frameNo].pinCnt--;
			if(dirty){
				bufDescTable[frameNo].dirty = dirty;
			}	
		}
	}

	void BufMgr::flushFile(const File* file) 
	{	
		// check whether the pages of file are valid to flush
		for (FrameId i = 0; i < numBufs; i++){
			if(bufDescTable[i].file == file){
				if(bufDescTable[i].pinCnt != 0){
					throw PagePinnedException(file->filename(),bufDescTable[i].pageNo,i);
				}
				if(!bufDescTable[i].valid){
					throw BadBufferException(i, bufDescTable[i].dirty, bufDescTable[i].valid, bufDescTable[i].refbit);
				}
			}

		}
		// flush the pages
		for (FrameId i = 0; i < numBufs; i++){	
			// Find all the pages which relate to the file
			if(bufDescTable[i].file == file){
				//(a) if the page is dirty, flush the page and set the dirty bit to false
				if(bufDescTable[i].dirty == true){


					bufDescTable[i].file->writePage(bufPool[i]);
					bufDescTable[i].dirty = false;
				}
				//(b) remove the page from the hashtable
				hashTable->remove(file, bufDescTable[i].pageNo);
				//(c) invoke the Clear() method
				bufDescTable[i].Clear();
			}
		}	

	}

	void BufMgr::allocPage(File* file, PageId &pageNo, Page*& page) 
	{
		
		FrameId frameNo = clockHand;
		
		allocBuf(frameNo);  //allocate a new frame
		bufPool[frameNo] = file->allocatePage(); //allocate new page
		page = &bufPool[frameNo];
		pageNo = page->page_number(); //get page number  
		bufDescTable[frameNo].Set(file, pageNo); //set up the file
		hashTable->insert(file, pageNo, frameNo); //insert entry into hashTable 
	}

	void BufMgr::disposePage(File* file, const PageId PageNo)
	{
		//check if is currently in the buffer pool 
		FrameId frameNo = 0; 
		hashTable->lookup(file, PageNo, frameNo);
		//clear
		bufDescTable[frameNo].Clear();
		hashTable->remove(file, PageNo); 
		file->deletePage(PageNo); //delete page from file
	}

	void BufMgr::printSelf(void) 
	{
		BufDesc* tmpbuf;
		int validFrames = 0;

		for (std::uint32_t i = 0; i < numBufs; i++)
		{
			tmpbuf = &(bufDescTable[i]);
			std::cout << "FrameNo:" << i << " ";
			tmpbuf->Print();

			if (tmpbuf->valid == true)
				validFrames++;
		}

		std::cout << "Total Number of Valid Frames:" << validFrames << "\n";
	}

}
