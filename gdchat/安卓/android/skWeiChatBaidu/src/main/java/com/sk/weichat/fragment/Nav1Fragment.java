package com.sk.weichat.fragment;


import android.content.res.ColorStateList;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Adapter;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.sk.weichat.R;
import com.sk.weichat.bean.circle.FindItem;
import com.sk.weichat.ui.base.EasyFragment;
import com.sk.weichat.util.SkinUtils;
import com.yanzhenjie.recyclerview.OnItemClickListener;

import java.util.ArrayList;
import java.util.List;

import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentTransaction;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;


/**
 * 导航1
 */
public class Nav1Fragment extends EasyFragment implements View.OnClickListener {

    public static List<FindItem> findItems;
    public List<FindItem> items = new ArrayList<>();
    private List<Fragment> fragments;
    private RecyclerView recy_tab;
    private MyAdapter mAdapter;
    private int selected = 0;
    public Nav1Fragment
            () {
    }

    @Override
    protected int inflateLayoutId() {
        return R.layout.fragment_venice;
    }

    @Override
    protected void onActivityCreated(Bundle savedInstanceState, boolean createView) {
        if (createView) {
            initView();
        }
    }

    @Override
    public void onResume() {
        super.onResume();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }


    private void initView() {
        items = findItems;
        mAdapter = new MyAdapter();
        recy_tab = (RecyclerView) findViewById(R.id.recy_tab);
        RecyclerView.LayoutManager layoutManager = new LinearLayoutManager(getActivity(), RecyclerView.HORIZONTAL,true);
        recy_tab.setLayoutManager(layoutManager);
        recy_tab.setAdapter(mAdapter);
        mAdapter.setmOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onItemClick(View view, int position) {
                changeFragment(position);
            }
        });
        fragments = new ArrayList<>();
        for (int i = 0; i < items.size(); i++) {
            WebItemFragment itemFragment = new WebItemFragment();
            itemFragment.homeUrl = items.get(i).getUrl();
            itemFragment.title = items.get(i).getTitle();
            fragments.add(itemFragment);
        }
        if (items.size() > 0) {
            changeFragment(0);
        }
    }


    private void changeFragment(int position) {

        FragmentTransaction transaction = getChildFragmentManager().beginTransaction();

        Fragment fragment = fragments.get(position);

//        if (!fragment.isAdded()) {// 未添加 add
//            transaction.add(R.id.main_content, fragment);
//        }else {
//            transaction.hide(fragments.get(position));
//        }
//        transaction.show(fragment);
        transaction.replace(R.id.main_content, fragment);
        transaction.commit();


    }

    public class MyAdapter extends RecyclerView.Adapter<MyAdapter.ViewHolder> {

        private OnItemClickListener onItemClickListener;

        public void setmOnItemClickListener(OnItemClickListener onItemClickListener) {
            this.onItemClickListener = onItemClickListener;
        }

        @Override
        public MyAdapter.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_web_title, parent, false);
            return new MyAdapter.ViewHolder(view);
        }

        @Override
        public void onBindViewHolder(final MyAdapter.ViewHolder holder, int position) {
            FindItem findItem = items.get(position);
            holder.name.setText(findItem.getTitle());
//            ColorStateList tabColor = SkinUtils.getSkin(getActivity()).getMainTabColorState();
//            holder.name.setTextColor(tabColor);
            if(selected == position){
                holder.lin.setBackgroundResource(R.drawable.btn_web_item_title_select);
            }else {
                holder.lin.setBackgroundResource(R.drawable.btn_web_item_title);
            }


            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (onItemClickListener != null) {
                        selected = position;
                        int position = holder.getLayoutPosition();
                        onItemClickListener.onItemClick(holder.itemView, position);
                        mAdapter.notifyDataSetChanged();
                    }
                }
            });
        }

        @Override
        public int getItemCount() {
            return items == null ? 0 : items.size();
        }

        class ViewHolder extends RecyclerView.ViewHolder {
            TextView name;
            LinearLayout lin;

            public ViewHolder(View itemView) {
                super(itemView);
                name =  itemView.findViewById(R.id.name);
                lin =  itemView.findViewById(R.id.lin);
            }
        }
    }


}
