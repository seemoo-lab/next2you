"""
Visualizations for the paper "Next2You: Robust Copresence Detection Based on Channel State Information",
by Mikhail Fomichev, Luis F. Abanto-Leon, Max Stiegler, Alejandro Molina, Jakob Link, Matthias Hollick,
in ACM Transactions on Internet of Things, vol. 1, Issue 1, 2021.
"""

import sys
import os
from glob import glob
from json import loads
from math import ceil
import matplotlib.pyplot as plt
import numpy as np


def plot_time_of_day_effect(filepath, auc_day=[], auc_night=0, band='2.4'):
    # Check if provided band is valid
    if band != '2.4' and band != '5':
        print('plot_time_of_day_effect: frequency band can only be "2.4" or "5"!')
        sys.exit(0)

    # Check if values are provided, otherwise use hardcoded values
    if not auc_day:
        if band == '2.4':
            # Values for morning, afternoon, and evening sessions
            auc_day = [[0.95477886, 0.97435771, 0.97664653],
                       [0.96771921, 0.9682607, 0.94419584],
                       [0.96434124, 0.94218209, 0.96534146]]

            # Value for night session
            auc_night = 0.9732294338572162
        else:
            # Values for morning, afternoon, and evening sessions
            auc_day = [[0.99154204, 0.99403971, 0.99562549],
                       [0.99299613, 0.99193402, 0.99218609],
                       [0.99511675, 0.99393499, 0.99600898]]

            # Value for night session
            auc_night = 0.9923261322131527

    # Filename of the plot
    filename = 'time-of-day-effect'

    # Define figure's size
    fig = plt.figure(figsize=(7, 5))

    # Bar width
    bar_width = 0.2
    # bar_width = 0.12

    # X spacing
    x_spacing = 0.00
    # x_spacing = 0.04

    # Plot labels
    day_labels = ['Morning', 'Afternoon', 'Evening']
    night_label = 'Night'

    # Index to keep track of time of day
    idx = 0

    # Iterate over auc_day values
    for aucd in auc_day:

        # Adjust X-axis
        if idx == 0:
            # Positions on X-axis
            x_axis = np.arange(len(day_labels))
        else:
            x_axis = [x + bar_width + x_spacing for x in x_axis]

        # Plot morning, afternoon, and evening sessions
        plt.bar(x_axis, aucd, width=bar_width, edgecolor='black', linewidth=0.6, label=day_labels[idx],
                zorder=3, capsize=6)

        # Increment idx
        idx += 1

    # Plot night session
    plt.bar(ceil(x_axis[-1]), auc_night, width=bar_width, edgecolor='black', linewidth=0.75, label=night_label,
            zorder=3, capsize=6)

    # Add grid to a plot
    plt.grid(True, axis='y', zorder=0)

    # Setup ticks font size
    plt.tick_params(axis='both', labelsize=18)

    # Add ticks in the middle of bars
    xticks_pos = [r + (bar_width + x_spacing) for r in range(len(day_labels))]
    xticks_pos.append(ceil(x_axis[-1]))

    # Add X-axis values
    if band == '2.4':
        plt.xticks(xticks_pos, ['Day 1', 'Day 2', 'Day 3', 'Day 4'])
    else:
        plt.xticks(xticks_pos, ['Day 5', 'Day 6', 'Day 7', 'Day 8'])

    plt.ylim([0.9, 1.0])
    plt.yticks(np.arange(0.9, 1.02, step=0.02))

    # X and Y axes name
    plt.xlabel('Office Experiment Days', fontsize=22)
    plt.ylabel('AUC', fontsize=22)

    # Add legend
    plt.legend(bbox_to_anchor=(0., 1.02, 1., .102), loc='lower left', ncol=len(day_labels) + 1, mode="expand",
               borderaxespad=0., fontsize=16.5,  handlelength=1.3, handletextpad=0.16)

    # Save plot
    plt.savefig(filepath + '/' + filename + '-' + band + ' GHz' + '.pdf', format='pdf', dpi=1000, bbox_inches='tight')

    # Show plot
    plt.show()


def plot_csi_measurements(filepath, col=[], ncol=[], band='2,4'):
    # Check if provided band is valid
    if band != '2.4' and band != '5':
        print('plot_csi_measurements: frequency band can only be "2.4" or "5"!')
        sys.exit(0)

    # Check if values are provided, otherwise use hardcoded values
    if not col:
        if band == '2.4':
            # The number of copresent and non-copresent CSI observations on day 1, 2, etc.
            col = [102030, 119215, 67501, 94371]
            ncol = [100057, 115869, 63372, 188699]
        else:
            # The number of copresent and non-copresent CSI observations on day 1, 2, etc.
            col = [128082, 122882, 128448, 97344]
            ncol = [250243, 244132, 267226, 178422]

    # Filename of the plot
    filename = 'csi-measurements'

    # Adjust font for 10^x
    plt.rc('font', size=14)

    # Define figure's size
    fig = plt.figure(figsize=(7, 5))

    # Bar width
    bar_width = 0.4
    # bar_width = 0.28

    # X-aixs
    x = np.arange(len(col))

    # Plot labels
    labels = ['Copresent', 'Non-copresent']

    # Plot the number of copresent and non-copresent CSI observations
    plt.bar(x, col, color='g', width=bar_width, edgecolor='black', linewidth=0.6, label=labels[0],
            zorder=3, capsize=6)

    plt.bar(x, ncol, color='r', width=bar_width, edgecolor='black', linewidth=0.6, label=labels[1],
            zorder=3, capsize=6, bottom=col)

    # Add grid to a plot
    plt.grid(True, axis='y', zorder=0)

    # Setup ticks font size
    plt.tick_params(axis='both', labelsize=18)

    # X and Y axes name
    plt.xlabel('Office Experiment Days', fontsize=22)
    plt.ylabel('CSI Measurements', fontsize=22)

    # Add 10^x for ticks (Y-axis)
    plt.ticklabel_format(style='sci', axis='y', scilimits=(0, 0), useMathText=True)

    # Add X-axis values
    if band == '2.4':
        plt.xticks(x, ('Day 1', 'Day 2', 'Day 3', 'Day 4 (Night)'))
        plt.yticks(np.arange(0, 3.1, step=1) * 100000)
    else:
        plt.xticks(x, ('Day 5', 'Day 6', 'Day 7', 'Day 8 (Night)'))
        plt.yticks(np.arange(0, 4.1, step=1) * 100000)

    # Add legend
    plt.legend(bbox_to_anchor=(0., 1.02, 1., .102), loc='center', ncol=len(labels), borderaxespad=0.,fontsize=16.5,
               handlelength=1.3, handletextpad=0.16)

    # Save plot
    plt.savefig(filepath + '/' + filename + '-' + band + ' GHz' + '.pdf', format='pdf', dpi=1000, bbox_inches='tight')

    # Show plot
    plt.show()


def ampl_phase_impact(filepath, aucs, band='2.4'):
    # Check if provided band is valid
    if band != '2.4' and band != '5':
        print('ampl_phase_impact: frequency band can only be "2.4" or "5"!')
        sys.exit(0)

    # Filename of the plot
    filename = 'impact-of-ampl-and-phase'

    # Define figure's size
    fig = plt.figure(figsize=(7, 5))

    # Put grid in the background
    plt.rcParams['axes.axisbelow'] = True

    # Bar width
    # bar_width = 0.22
    bar_width = 0.2

    # X spacing
    x_spacing = 0.00

    # Plot labels
    scen = ['Office', 'Apart.', 'House', 'P. Cars', 'M. Cars', 'Heterog.', 'Frame', 'Power']
    labels = ['Raw Phase', 'Sanitized Phase', 'Magnitude', 'Magnitude and Phase']
    colors = ['C5', 'C8', '#0e87cc', '#ec2d01']
    # colors = ['C5', 'C8', 'C0', 'C3']

    # Index to keep track of time of day
    idx = 0

    # Iterate over auc_day values
    for auc in aucs:

        # Adjust X-axis
        if idx == 0:
            # Positions on X-axis
            x_axis = np.arange(len(scen))
        else:
            x_axis = [x + bar_width + x_spacing for x in x_axis]

        # Plot morning, afternoon, and evening sessions
        plt.bar(x_axis, auc, width=bar_width, edgecolor=None,
                color=colors[idx], linewidth=0.6, label=labels[idx], capsize=6)

        # Increment idx
        idx += 1

    # Add grid to a plot
    plt.grid(True, axis='y')

    # Setup ticks font size
    plt.tick_params(axis='both', labelsize=18)

    # Add ticks in the middle of bars
    xticks_pos = [r + (bar_width + 0.5 * bar_width + x_spacing) for r in range(len(scen))]
    plt.xticks(xticks_pos, scen)

    # Rotate xticks
    plt.xticks(rotation=30)

    # X and Y axes name
    plt.xlabel('Scenario', fontsize=22)
    plt.ylabel('AUC', fontsize=22)

    # Set Y-ticks
    plt.ylim([0.4, 1.02])
    plt.yticks(np.arange(0.4, 1.1, 0.2))

    # Add legend
    plt.legend(bbox_to_anchor=(0., 1.02, 1., .15), loc='center', ncol=2, borderaxespad=0.,fontsize=16,
               handlelength=1.3, handletextpad=0.16)

    # Save plot
    plt.savefig(filepath + '/' + filename + '-' + band + ' GHz' + '.pdf', format='pdf', dpi=1000,
                bbox_inches='tight')

    # Show plot
    plt.show()


def reformat_auc(in_auc):
    # Initialize out_auc
    out_auc = [[] for i in range(len(in_auc[0]))]

    # Reformat auc
    for auc in in_auc:
        out_auc[0].append(auc[1])
        out_auc[1].append(auc[0])
        out_auc[2].append(auc[2])
        out_auc[3].append(auc[3])

    return out_auc


def prototype_stat(log_path, band, win, scen):
    # Sanity checks
    # Check if provided band is valid
    if band != '2.4' and band != '5':
        print('prototype_stat: frequency band can only be "2.4" or "5"!')
        sys.exit(0)

    if win != '5' and win != '10':
        print('prototype_stat: windows length can only be "5" or "10"!')
        sys.exit(0)

    if scen != 'Hallway' and scen != 'Office 1' and scen != 'Office 2' and scen != 'Office 3':
        print('prototype_stat: the following scenarios are allowed: "Hall", "Office 1", "Office 2", "Office 3"!')
        sys.exit(0)

    # File that contains FAR and FRRs
    fband = '2400 MHz'
    if band == '5':
        fband = '5000 MHz'

    wlen = '5-sec'
    if win == '10':
        wlen = '10-sec'

    filepath = log_path + '/' + fband + '/' + wlen + '/' + scen + '.txt'

    # Check if file exists
    if not os.path.exists(filepath):
        print('Error: Root path "%s" does not exist!' % filepath)
        sys.exit(0)

    # Store copresent and non-copresent stat
    copres = []
    ncopres = []
    ambig = 0

    # Open file for reading
    with open(filepath, 'r') as f:
        lines = [line.rstrip() for line in f]

    # Index to track lines
    idx = 0

    # Iterate over lines in the file
    for line in lines:
        if 'Number of messages received (Pos/Neg):' in line:
            # Get the ratio between positive and negative observations in majority vote
            mv = line.split(':')

            # Check if we have data
            if mv[1]:
                # Get the majority vote ratio
                mv = mv[1].strip()

                # Convert list of str to list of int
                mv = list(map(int, mv.split('/')))

                # Get the device number
                if 'Device number:' in lines[idx-2]:
                    devn = lines[idx - 2].split(':')
                    devn = devn[1].strip()
                else:
                    print('prototype_stat: error in line (Device number) %s, check the file!' % lines[idx-2])
                    sys.exit(0)

                # Store copres and non-copres instances
                if mv[0] > mv[1]:
                    copres.append(devn)
                elif mv[0] < mv[1]:
                    ncopres.append(devn)
                else:
                    ambig += 1

            else:
                print('prototype_stat: error in line (Pos/Neg) %s, check the file!' % line)
                sys.exit(0)

        # Increment idx
        idx += 1

    return copres, ncopres, ambig


def get_conf_matrix(copres, ncopres, scen='Hall'):
    # Set default FAR and FRR
    far = -1
    frr = -1

    # Check the scenario and compute the error rates
    if scen == 'Hallway':
        far = len(copres) / (len(ncopres) + len(copres))
    elif scen == 'Office 3':
        # Devices located in Office 3
        dev = ['1', '2', '4', '5']
    elif scen == 'Office 2':
        # Devices located in Office 2
        dev = ['7', '8', '9', '14']
    elif scen == 'Office 1':
        # Devices located in Office 1
        dev = ['10', '11', '12', '13']

    if scen != 'Hallway':
        # TP, TN, FP, FN
        tp = 0
        fp = 0
        tn = 0
        fn = 0

        # Get TP and FP
        for d in dev:
            tp += copres.count(d)

        fp = len(copres) - tp

        # Get TN and FN
        for d in dev:
            fn += ncopres.count(d)

        tn = len(ncopres) - fn

        far = fp / (fp + tn)
        frr = fn / (fn + tp)

    return far, frr


def rrr_plot(log_path, filepath, band='2.4'):
    # Check if provided band is valid
    if band != '2.4' and band != '5':
        print('rrr_plot: frequency band can only be "2.4" or "5"!')
        sys.exit(0)

    # Filename of the plot
    filename = 'rrr-effect'

    # Set band folder
    bfolder = '2400 MHz'
    n_feat = 112
    if band == '5':
        bfolder = '5000 MHz'
        n_feat = 484

    # Read log files
    log_files = glob(log_path + '/*/' + bfolder + '/*.json', recursive=True)

    # Store data here
    log_data = {}

    # Set splitter
    splitter = '/'
    if '\\' in log_files[0]:
        splitter = '\\'

    # Iterate over log files
    for log_file in log_files:
        # Open and read data JSON file storing the result in dict
        with open(log_file, 'r') as f:
            log_data[log_file.split(splitter)[-1].split('-')[0]] = loads(f.read())

    # Plot data
    plot_data = {}

    # Top features
    top_feat = {}

    # Iterate over log data
    for k,v in log_data.items():
        print(k)
        if band == '5' and k == 'parking cars':
            plot_data[k] = get_plot_data(v, n_feat, parked_cars_handler(v))
            top_feat[k] = feature_stat(v, band, parked_cars_handler(v))
        else:
            plot_data[k] = get_plot_data(v, n_feat)
            top_feat[k] = feature_stat(v, band)
        print()

    get_feat_similarity(top_feat)

    # Put grid in the background
    plt.rcParams['axes.axisbelow'] = True

    # Define figure's size
    fig = plt.figure(figsize=(7, 5))

    # Plot settings
    plot_settings = [[':', 'p', 'C0'], ['--', 'o', 'C1'], ['-', 'H', 'C2'], [[3, 1, 1, 1, 1, 1], '^', 'C3'],
                     [[3, 1, 1, 1], 's', 'C4'], [[1, 1], 'D', 'C8'], [[5, 1], 'v', 'C6'], ['-.', 'X', 'C5']]

    # Index to adjust plot settings
    idx = 0

    scen = ['office', 'urban flat', 'rural flat', 'parking cars', 'moving cars', '6p', 'beacon', 'power']
    labels = ['Office', 'Apart.', 'House', 'P. Cars', 'M. Cars', 'Heterog.', 'Frame', 'Power']

    # Iterate over scenarios
    for s in scen:
        # Default marker sizes
        mew = 7
        ms = 14

        # Adjust p, o, and H
        if idx < 3:
            mew = 8
            ms = 16

        # Check if we have customized line (list) or one of defaults (string)
        if isinstance(plot_settings[idx][0], str):
            # Plot FRRs (Y) vs. FARs(X)
            plt.plot(plot_data[s][1], plot_data[s][0], linestyle=plot_settings[idx][0], marker=plot_settings[idx][1],
                     color=plot_settings[idx][2], label=labels[idx], linewidth=6.5, mew=mew, ms=ms)

        elif isinstance(plot_settings[idx][0], list):
            # Plot FRRs (Y) vs. FARs(X)
            plt.plot(plot_data[s][1], plot_data[s][0], dashes=plot_settings[idx][0], marker=plot_settings[idx][1],
                     color=plot_settings[idx][2], label=labels[idx], linewidth=6.5, mew=mew, ms=ms)

        # Increment idx
        idx += 1

    # Invert X-axis
    plt.gca().invert_xaxis()

    # Add grid to a plot
    plt.grid(True, axis='both')

    # Setup ticks font size
    plt.tick_params(axis='both', labelsize=18)

    # X and Y axes name
    plt.xlabel('Number of Features', fontsize=22)
    plt.ylabel('AUC', fontsize=22)

    # Set Y-ticks
    plt.yticks(np.arange(0.7, 1.05, 0.1))

    if band == '2.4':
        plt.xticks(np.arange(110, 40, -15))

    lgnd = plt.legend(ncol=2, fontsize=16, markerscale=1.0, handlelength=1.8, handletextpad=0.18)
    for line in lgnd.get_lines():
        line.set_linewidth(6)

    # Save plot
    plt.savefig(filepath + '/' + filename + '-' + band + ' GHz.pdf', format='pdf', dpi=1000,
                bbox_inches='tight')

    # Show plot
    plt.show()


def idx_to_str(idx):
    # Make it 01, 02, etc.
    if idx < 10:
        return '0' + str(idx)

    return str(idx)


def feature_stat(res, band, handler=None):
    # Set amplitude and phase feature ranges
    ra = (0, 55)
    rp = (56, 111)

    if band == '5':
        ra = (0, 241)
        rp = (242, 483)

    # Store top features
    top_feat = []

    # Check if we need to handle parked cars at 5 GHz
    if handler is None:
        # Iterate over res
        for i in range(1, len(res)):
            # Store features from the 1st model
            if i == 2:
              top_feat = ampl

            # Amplitude and phase lists
            ampl = []
            phase = []

            # Iterate over feature list
            for f in res[idx_to_str(i)]['Feat']:
                # Add feature to amplitude list
                if ra[0] <= f <= ra[-1]:
                    ampl.append(f)

                # Add feature to phase list
                if rp[0] <= f <= rp[-1]:
                    phase.append(f)

            # Print stat
            print('%s: ampl = %d (%s), phase = %d (%s)' % (idx_to_str(i), len(ampl), sorted(ampl),
                                                           len(phase), sorted(phase)))
    else:
        # Index to keep track of loop iterations
        idx = 0

        # Iterate over handler
        for k,v in handler.items():
            # Ignore the full model
            if len(v) > 0:
                # Store features from the 1st model
                if idx == 1:
                    top_feat = ampl

                # Amplitude and phase lists
                ampl = []
                phase = []

                # Iterate over feature list
                for f in v:
                    # Add feature to amplitude list
                    if ra[0] <= f <= ra[-1]:
                        ampl.append(f)

                    # Add feature to phase list
                    if rp[0] <= f <= rp[-1]:
                        phase.append(f)

                # Print stat
                print('%s: ampl = %d (%s), phase = %d (%s)' % (k, len(ampl), sorted(ampl), len(phase), sorted(phase)))

                # Increment idx
                idx += 1

    return top_feat


def get_feat_similarity(scen_feat):
    # Scenarios
    scen = ['office', 'urban flat', 'rural flat', 'parking cars', 'moving cars', '6p', 'beacon', 'power']

    # Iterate over scenarios
    for i in range(len(scen)):
        for j in range(i + 1, len(scen)):
            print('%s-%s: %s' % (scen[i], scen[j], sorted(list(set(scen_feat[scen[i]]) & set(scen_feat[scen[j]])))))
        print()


def get_plot_data(res, n_feat, handler=None):
    # Lists storing AUC and exluded features
    auc = []
    feat = []

    # Count features
    f_count = n_feat

    # Check if we need to handle parked cars at 5 GHz
    if handler is None:
        # Iterate over dict
        for k,v in res.items():
            # if v['Keras'] > 0.8:
            # Add AUC and number of features to respective lists
            auc.append(v['Keras'])
            feat.append(f_count - v['Feat_n'])

            # Update feature count
            f_count -= v['Feat_n']
    else:
        # Deal with the parking cars case at 5 GHz
        for k,v in handler.items():
            # Add AUC and number of features to respective lists
            auc.append(res[idx_to_str(k)]['Keras'])
            feat.append(f_count - len(v))

            # Update feature count
            f_count -= len(v)

    return auc, feat


def parked_cars_handler(log_data):
    # Store unique features and feature count
    uniq_feat = []
    f_count = {}

    # Iterate before duplicates occur
    for i in range(14):
        # Store feature count
        f_count[i] = log_data[idx_to_str(i)]['Feat']

        # Store unique features
        uniq_feat.extend(log_data[idx_to_str(i)]['Feat'])

    # Iterate after duplicates occur
    for i in range(14, len(log_data)):
        # Find duplicates
        duplicates = list(set(uniq_feat) & set(log_data[idx_to_str(i)]['Feat']))

        # Get new unique features
        new_feat = []
        for f in log_data[idx_to_str(i)]['Feat']:
            if f not in duplicates:
                new_feat.append(f)

        # Update f_count
        if len(new_feat) > 0:
            f_count[i] = new_feat

        # Extend unique features
        uniq_feat.extend(new_feat)

    return f_count


def rrr_defense(filepath, plot_data, band, extra_flag=False):
    # Check if provided band is valid
    if band != '2.4' and band != '5':
        print('rrr_defense: frequency band can only be "2.4" or "5"!')
        sys.exit(0)

    # Filename of the plot
    filename = 'rrr-defense'

    # Define figure's size
    fig = plt.figure(figsize=(7, 5))

    # Put grid in the background
    plt.rcParams['axes.axisbelow'] = True

    # Threshold value
    if len(plot_data) == 3:             # moving-parked 5 GHz
        # thr = 0.9
        thr = 0.7561

        # Bar width
        bar_width = 0.12

        # X-axis labels
        x_labels = ['01', '02', '03']

    elif len(plot_data) == 5:           # parked-moving 2.4 GHz

        # Bar width
        bar_width = 0.33
        # bar_width = 0.23

        if extra_flag:                  # office-parked 5 GHz
            thr = 0.8981

            x_labels = ['01', '03', '07', '12', '15']
        else:                           # parked-moving 2.4 GHz
            # thr = 0.86    # cars
            thr = 0.7248    # cars

            # X-axis labels
            x_labels = ['01', '02', '03', '04', '05']

    elif len(plot_data) == 6:           # moving-parked 2.4 GHz
        # thr = 0.89
        thr = 0.8228

        # Bar width
        bar_width = 0.38
        # bar_width = 0.28

        # X-axis labels
        x_labels = ['01', '02', '03', '04', '05', '06']

    elif len(plot_data) == 9:           # parking-moved 5 GHz
        # thr = 0.89
        thr = 0.8473

        # Bar width
        bar_width = 0.45

        # X axis labels
        x_labels = ['01', '04', '07', '10', '13', '16', '19', '25', '36']

    # X range
    x_range = np.arange(1, len(plot_data) + 1, 1)

    # Model performance bars
    plt.bar(x_range, plot_data, width=bar_width, edgecolor=None, linewidth=0.6, capsize=6)

    # Threshold (horizontal line)
    plt.axhline(y=thr, color='r', linestyle='--', linewidth=6)

    # Set X-ticks
    plt.xticks(x_range, x_labels)

    # Set Y-ticks
    plt.ylim([0.6, 0.92])
    plt.yticks(np.arange(0.6, 0.9, step=0.1))
    # plt.yticks(np.arange(0.0, 1.05, 0.2))

    # Add grid to a plot
    plt.grid(True, axis='y')

    # Setup ticks font size
    plt.tick_params(axis='both', labelsize=18)

    # X and Y axes name
    plt.xlabel('RRR Models', fontsize=22)
    plt.ylabel('AUC', fontsize=22)

    # Save plot
    plt.savefig(filepath + '/' + filename + '-' + band + ' GHz.pdf', format='pdf', dpi=1000,
                bbox_inches='tight')

    # Show plot
    plt.show()


# Let's do some plotting here
filepath = 'C:/Users/mfomichev/Desktop' # --> adjust this on your machine

# Plot time of day effect, set the band param to either '2.4' (for 2.4 GHz band) or '5' --> Figure 10 in the paper
plot_time_of_day_effect(filepath, band='2.4')

# Plot the number of CSI measurements on different days, set the band param to either '2.4' (for 2.4 GHz band) or '5'
# --> Figure 9 in the paper
plot_csi_measurements(filepath, band='5')

# Calculate FAR and FRR for the real-time Next2You prototype performance --> Table 4 in the paper
log_path = 'C:/Users/mfomichev/Desktop/next2you-results/real-time_prototype'
band = '5'  # Frequency band: either 2.4 or 5
win = '10'  # CSI measurement window: either 5 or 10
loc = 'Hallway'  # Location: Office 1, Office 2, Office 3, or Hallway

copres, ncopres, ambig = prototype_stat(log_path, band, win, loc)
far, frr = get_conf_matrix(copres, ncopres, loc)

if frr == -1:
    frr = 'n/a'
    print('far = %.3f, frr = %s' % (far, frr))
else:
    print('far = %.3f, frr = %.3f' % (far, frr))
print()

# Plot the application of the Right for the Right Reasons to the CSI data, set the band param to either '2.4'
# (for 2.4 GHz band) or '5' --> Figure 11 in the paper
log_path = 'C:/Users/mfomichev/Desktop/next2you-results/RRR-logs'
rrr_plot(log_path, filepath, band='2.4')

# Plot the Next2You AUC performance on different parts of the CSI data: phase (raw/sanitized) and magnitude, set the auc
# param to either auc1 for 2.4 GHz band or auc2 for 5 GHz band, and similarly the band param --> Figure 12 in the paper
# 2.4 GHz
auc1 = [[0.5924, 0.5980, 0.9485, 0.958], [0.5006, 0.5000, 0.9532, 0.961], [0.5653, 0.5825, 0.9755, 0.993],
        [0.8267, 0.8233, 0.9906, 0.998], [0.8559, 0.8450, 0.9829, 0.996], [0.6397, 0.6277, 0.9532, 0.982],
        [0.6269, 0.6213, 0.9758, 0.988], [0.7165, 0.7046, 0.9906, 0.995]]

# 5 GHz
auc2 = [[0.6747, 0.6872, 0.9918, 0.995], [0.5304, 0.5465, 0.9718, 0.984], [0.5577, 0.5578, 0.9646, 0.984],
        [0.9293, 0.9272, 0.9971, 0.999], [0.7064, 0.7129, 0.9491, 0.997], [0.7028, 0.7176, 0.9947, 0.996],
        [0.6780, 0.6732, 0.9738, 0.993], [0.6604, 0.6669, 0.9987, 0.999]]

ampl_phase_impact(filepath, reformat_auc(auc1), band='5')

# Plot the application of the RRR method to withstand attack --> Figure 13 in the paper. Use the below commands as is to
# produce plots for 2.4 GHz and 5 GHz bands (i.e., Figure 13a and 13b, respectively)
# RRR car defense data
parked_mov1 = [0.7094, 0.7158, 0.6865, 0.7369, 0.7797]  # 2.4 GHz
parked_mov2 = [0.8377, 0.7773, 0.8008, 0.8372, 0.9100, 0.9063, 0.9043, 0.9210, 0.9111]  # 5 GHz

mov_parked1 = [0.7845, 0.7890, 0.7337, 0.7560, 0.7572, 0.7365]  # 2.4 GHz
mov_parked2 = [0.7213, 0.6689, 0.7002]  # 5 GHz

office_parked = [0.8734, 0.8613,  0.8420, 0.8184, 0.7132]   # 5 GHz subset (1, 3, 7, 12, 15)

rrr_defense(filepath, office_parked, '5', True)
rrr_defense(filepath, mov_parked1, '2.4')
